# MASt3R-SLAM RTX 5080 兼容性修复

## RTX 5080 环境配置步骤

### 系统要求

| 组件 | 版本要求 | 说明 |
|------|---------|------|
| **GPU** | NVIDIA RTX 5080 | Blackwell架构 (Compute Capability 10.0) |
| **CUDA Toolkit** | 12.6 或 12.8+ | 必须 ≥ 12.6，推荐12.8 |
| **Python** | 3.11 | 其他版本未测试 |
| **PyTorch** | 2.10.dev (cu128) 或 2.5.1+ | 需要支持最新GPU的版本 |
| **操作系统** | Ubuntu 20.04+ / Linux | Windows用户请使用WSL2 |
| **GCC** | 9+ | 用于编译CUDA扩展 |
| **Ninja** | 最新版 | pip会自动安装 |

### 完整安装步骤

#### 1. 创建Conda环境

```bash
conda create -n mast3r python=3.11
conda activate mast3r
```

#### 2. 检查系统CUDA版本

```bash
nvcc --version
```

确认输出显示 CUDA 12.6 或更高版本。

#### 3. 安装PyTorch

**对于RTX 5080，推荐使用以下版本：**

```bash
# 方案1: 使用PyTorch 2.10.dev (开发版，支持最新GPU)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# 方案2: 如果官方已发布2.5.1 + CUDA 12.8，可以使用
# conda install pytorch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 pytorch-cuda=12.8 -c pytorch -c nvidia
```

**注意**: RTX 5080 需要较新的PyTorch和CUDA版本才能获得最佳支持。

#### 4. 验证PyTorch和CUDA

```bash
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}')"
```

预期输出类似:
```
PyTorch: 2.10.0.dev20251122+cu128
CUDA available: True
CUDA version: 12.8
```

#### 5. 克隆仓库

```bash
cd ~/slam  # 或你选择的工作目录
git clone https://github.com/rmurai0610/MASt3R-SLAM.git --recursive
cd MASt3R-SLAM/

# 如果已经克隆但没有使用 --recursive
# git submodule update --init --recursive
```

#### 6. 配置pip镜像源（国内用户推荐）

```bash
# 配置清华大学PyPI镜像源，大幅提升下载速度
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set install.trusted-host pypi.tuna.tsinghua.edu.cn
```

#### 7. 应用RTX 5080兼容性补丁

**在安装依赖之前，需要先应用下面的代码修复**（见"修改的文件"部分）

#### 8. 安装依赖包

```bash
# 8.1 安装MASt3R (包含curope CUDA扩展)
pip install -e thirdparty/mast3r --no-build-isolation

# 8.2 安装in3d
pip install -e thirdparty/in3d

# 8.3 安装MASt3R-SLAM主包
pip install --no-build-isolation -e .
```

#### 9. 下载模型权重

```bash
mkdir -p checkpoints/
wget https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric.pth -P checkpoints/
wget https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_trainingfree.pth -P checkpoints/
wget https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_codebook.pkl -P checkpoints/
```

#### 10. 验证安装

```bash
python -c "
import sys
sys.path.insert(0, 'thirdparty/mast3r')
import torch
import mast3r
import dust3r
import mast3r_slam
print('✅ All packages imported successfully!')
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
"
```

#### 11. 运行测试

```bash
# 下载示例数据集
bash ./scripts/download_tum.sh

# 运行SLAM
python main.py --dataset datasets/tum/rgbd_dataset_freiburg1_room/ --config config/calib.yaml
```

---

## 快速导航

- [环境配置步骤](#rtx-5080-环境配置步骤) - 从零开始配置RTX 5080环境
- [问题描述](#问题描述) - 了解为什么需要这些修复
- [修改的文件](#修改的文件) - 需要修改的代码清单
- [安装方法](#安装方法) - pip镜像配置和安装命令
- [验证安装](#验证安装) - 测试安装是否成功
- [常见问题](#常见问题) - 排查安装问题

---

## 问题描述

在RTX 5080 (Blackwell架构) + CUDA 12.6 环境下安装MASt3R-SLAM时会遇到以下编译错误：

1. **curope扩展编译失败**: `nvcc fatal: Unsupported gpu architecture 'compute_100'`
2. **matching_kernels.cu编译失败**: `no suitable conversion function from "const at::DeprecatedTypeProperties" to "c10::ScalarType"`
3. **gn_kernels.cu编译失败**: `name followed by "::" must be a class or namespace name` (torch::linalg::norm)

## 根本原因

1. **CUDA架构不兼容**: PyTorch 2.10.dev生成的架构标志包含`compute_100`和`compute_120`,但CUDA 12.6不支持
2. **PyTorch API变更**: 
   - `.type()`方法在PyTorch 2.10+中已废弃,需要使用`.scalar_type()`
   - `torch::linalg::norm`在CUDA kernel中不可用,需要使用`torch::norm`

## 修改的文件

### 1. `thirdparty/mast3r/dust3r/croco/models/curope/setup.py`

**修改内容**: 使用CUDA 12.6支持的GPU架构列表,包括sm_90 (Hopper)来提供RTX 50系列的前向兼容性。

**原因**: CUDA 12.6不支持compute_100/120架构。

```python
# Copyright (C) 2022-present Naver Corporation. All rights reserved.
# Licensed under CC BY-NC-SA 4.0 (non-commercial use only).

from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension

# Use architectures compatible with CUDA 12.6
# RTX 5080 (Blackwell) is forward compatible with sm_90 (Hopper)
# CUDA 12.6 doesn't support compute_100/120 yet
all_cuda_archs = [
    '-gencode', 'arch=compute_70,code=sm_70',   # V100
    '-gencode', 'arch=compute_75,code=sm_75',   # RTX 20 series
    '-gencode', 'arch=compute_80,code=sm_80',   # A100
    '-gencode', 'arch=compute_86,code=sm_86',   # RTX 30 series
    '-gencode', 'arch=compute_89,code=sm_89',   # RTX 40 series / Ada
    '-gencode', 'arch=compute_90,code=sm_90',   # H100 / Hopper (forward compatible with RTX 50 series)
]

setup(
    name = 'curope',
    ext_modules = [
        CUDAExtension(
                name='curope',
                sources=[
                    "curope.cpp",
                    "kernels.cu",
                ],
                extra_compile_args = dict(
                    nvcc=['-O3','--ptxas-options=-v',"--use_fast_math"]+all_cuda_archs, 
                    cxx=['-O3'])
                )
    ],
    cmdclass = {
        'build_ext': BuildExtension
    })
```

### 2. `thirdparty/mast3r/dust3r/croco/models/curope/kernels.cu`

**修改内容**: 将`tokens.type()`改为`tokens.scalar_type()`以兼容PyTorch 2.10+。

在第101行:
```cpp
// 原代码:
AT_DISPATCH_FLOATING_TYPES_AND_HALF(tokens.type(), "rope_2d_cuda", ([&] {

// 修改为:
AT_DISPATCH_FLOATING_TYPES_AND_HALF(tokens.scalar_type(), "rope_2d_cuda", ([&] {
```

### 3. `thirdparty/mast3r/dust3r/croco/models/curope/pyproject.toml` (新建)

**作用**: 为curope包指定构建依赖,确保在隔离构建环境中torch可用。

```toml
[build-system]
requires = ["setuptools", "wheel", "torch", "ninja"]
build-backend = "setuptools.build_meta"
```

### 4. `mast3r_slam/backend/src/matching_kernels.cu`

**修改内容**: PyTorch API兼容性修复。

第103行:
```cpp
// 原代码:
AT_DISPATCH_FLOATING_TYPES_AND_HALF(D11.type(), "refine_matches_kernel", ([&] {

// 修改为:
AT_DISPATCH_FLOATING_TYPES_AND_HALF(D11.scalar_type(), "refine_matches_kernel", ([&] {
```

### 5. `mast3r_slam/backend/src/gn_kernels.cu`

**修改内容**: PyTorch linalg API兼容性修复。

在第802、1219、1629行:
```cpp
// 原代码:
delta_norm = torch::linalg::norm(dx, std::optional<c10::Scalar>(), {}, false, {});

// 修改为:
delta_norm = torch::norm(dx);
```

**原因**: `torch::linalg` 命名空间在CUDA kernel中不可用,需要使用 `torch::norm`。

### 6. `pyproject.toml`

**修改内容**: lietorch依赖配置。

```toml
# 原代码:
"lietorch @ git+https://github.com/princeton-vl/lietorch.git",

# 修改为:
"lietorch",  # Already installed, no need to clone from GitHub
```

## 安装方法

### 配置pip镜像源（国内用户推荐）

```bash
# 配置清华大学PyPI镜像源
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set install.trusted-host pypi.tuna.tsinghua.edu.cn
```

### 安装各个组件

按顺序安装:

```bash
cd /home/zhuke/slam/MASt3R-SLAM
conda activate mast3r

# 1. 安装MASt3R (包含curope扩展)
pip install -e thirdparty/mast3r --no-build-isolation

# 2. 安装in3d
pip install -e thirdparty/in3d

# 3. 安装MASt3R-SLAM主包
pip install --no-build-isolation -e .
```

## 技术说明

### GPU架构兼容性
- **RTX 5080架构**: Blackwell (Compute Capability 10.0)
- **前向兼容方案**: 通过 `sm_90` (Hopper架构) 提供前向兼容性
- **原因**: CUDA 12.6 尚不原生支持 `compute_100/120` 架构标志

### CUDA版本说明
- **CUDA 12.6**: 当前可用，需要修改代码移除 compute_100/120 架构
- **CUDA 12.8+**: 未来版本将原生支持 Blackwell 架构

### 测试环境
本修复方案已在以下环境测试通过：
```
GPU: NVIDIA RTX 5080
CUDA: 12.6.85
PyTorch: 2.10.0.dev20251122+cu128
Python: 3.11
OS: Ubuntu (Linux 6.8.0)
```

## 验证安装

```bash
# 验证所有包
python -c "
import sys
sys.path.insert(0, 'thirdparty/mast3r')
import torch
import mast3r
import dust3r
import mast3r_slam
print('✅ All packages imported successfully!')
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
"
```

## 常见问题

### numpy版本冲突警告
安装完成后可能会看到numpy版本冲突警告:
```
opencv-python requires numpy>=2, but you have numpy 1.26.4
```

这通常不影响实际使用,可以忽略。如果遇到运行时问题,可以尝试:
```bash
pip install 'numpy>=2,<2.3.0'
```

## 故障排查

### 问题1: `nvcc fatal: Unsupported gpu architecture 'compute_100'`

**原因**: CUDA 12.6不支持compute_100架构。

**解决**: 确保已修改 `curope/setup.py`，移除compute_100/120，使用sm_90。

### 问题2: `no suitable conversion function from "const at::DeprecatedTypeProperties"`

**原因**: PyTorch 2.10+ API变更。

**解决**: 
- 修改 `kernels.cu`: `tokens.type()` → `tokens.scalar_type()`
- 修改 `matching_kernels.cu`: `D11.type()` → `D11.scalar_type()`

### 问题3: `name followed by "::" must be a class or namespace name`

**原因**: `torch::linalg::norm` 在CUDA kernel中不可用。

**解决**: 修改 `gn_kernels.cu`: `torch::linalg::norm(dx, ...)` → `torch::norm(dx)`

### 问题4: 下载速度慢

**解决**: 配置国内pip镜像源（见安装步骤）

### 问题5: `Failed to connect to github.com`

**原因**: lietorch需要从GitHub克隆。

**解决**: 
1. lietorch通常已预装，修改 `pyproject.toml` 使用已安装版本
2. 或配置Git代理：`git config --global http.proxy http://127.0.0.1:7890`

### 问题6: CUDA版本不匹配警告

```
The detected CUDA version (12.6) has a minor version mismatch with the version that was used to compile PyTorch (12.8)
```

**说明**: 这是警告不是错误，通常不影响使用。CUDA 12.6可以运行为12.8编译的PyTorch。

## 参考链接

- [MASt3R-SLAM 官方仓库](https://github.com/rmurai0610/MASt3R-SLAM)
- [PyTorch 官方文档](https://pytorch.org/get-started/locally/)
- [CUDA Toolkit 下载](https://developer.nvidia.com/cuda-downloads)
- [RTX 50系列发布说明](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/)

## 贡献

如果你在其他环境（不同的CUDA版本、PyTorch版本、GPU型号）测试成功，欢迎补充信息。

## 日期
2025-11-26

最后更新: 2025-11-26

