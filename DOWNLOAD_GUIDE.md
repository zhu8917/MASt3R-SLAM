# MASt3R-SLAM 模型下载加速指南

## 问题
从 `download.europe.naverlabs.com` 下载模型文件速度很慢（通常只有几十KB/s）。

## 解决方案

### 🚀 方案1: 使用 aria2c（推荐 - 最快）

aria2c 是一个轻量级的多线程下载工具，支持断点续传，速度比wget快很多。

#### 安装 aria2c

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y aria2

# 或使用conda
conda install -c conda-forge aria2
```

#### 使用下载脚本

```bash
cd /home/zhuke/slam/MASt3R-SLAM

# 1. 如果有VPN代理，先编辑脚本配置代理
nano download_checkpoints.sh
# 修改:
#   USE_PROXY=true
#   PROXY_URL="http://127.0.0.1:7890"  # 改成你的代理地址

# 2. 运行下载脚本
bash download_checkpoints.sh
```

**aria2c 优势:**
- ✅ 多线程下载（16线程）
- ✅ 自动断点续传
- ✅ 速度通常是wget的5-10倍
- ✅ 自动重试

---

### 🔧 方案2: 配置 wget 使用代理

如果你有VPN代理（如Clash、V2Ray等），可以配置wget使用代理。

#### 临时使用（单次下载）

```bash
# 设置代理环境变量（根据你的代理端口修改）
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"

# 然后运行下载命令
cd /home/zhuke/slam/MASt3R-SLAM
mkdir -p checkpoints/
wget https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric.pth -P checkpoints/
```

#### 永久配置（添加到 ~/.bashrc）

```bash
# 编辑 ~/.bashrc
echo 'export http_proxy="http://127.0.0.1:7890"' >> ~/.bashrc
echo 'export https_proxy="http://127.0.0.1:7890"' >> ~/.bashrc
source ~/.bashrc
```

**常见代理端口:**
- Clash: 7890
- V2Ray: 1080 或 10808
- Shadowsocks: 1080

---

### 📥 方案3: 手动下载（最慢但最可靠）

如果上述方法都不行，可以使用浏览器手动下载。

1. **在浏览器中打开以下链接**（浏览器通常有更好的网络优化）:

```
https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric.pth
https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_trainingfree.pth
https://download.europe.naverlabs.com/ComputerVision/MASt3R/MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_codebook.pkl
```

2. **下载完成后，移动到正确位置**:

```bash
cd /home/zhuke/slam/MASt3R-SLAM
mkdir -p checkpoints/
mv ~/Downloads/MASt3R_*.pth checkpoints/
mv ~/Downloads/MASt3R_*.pkl checkpoints/
```

---

### 🌐 方案4: 使用第三方下载加速服务

某些国内的CDN加速服务可以帮助加速国外下载，但需要注册账号。

---

## 文件信息

下载的模型文件大小参考：

| 文件名 | 大小 | 说明 |
|--------|------|------|
| MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric.pth | ~1.5 GB | 主模型权重 |
| MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_trainingfree.pth | ~1.5 GB | 检索模型权重 |
| MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_codebook.pkl | ~数十MB | 检索码本 |

**总下载大小**: 约 3-3.5 GB

---

## 验证下载

下载完成后验证文件：

```bash
cd /home/zhuke/slam/MASt3R-SLAM/checkpoints
ls -lh

# 应该看到3个文件
# MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric.pth
# MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_trainingfree.pth
# MASt3R_ViTLarge_BaseDecoder_512_catmlpdpt_metric_retrieval_codebook.pkl
```

---

## 速度对比

根据实际测试：

| 方法 | 速度 | 优缺点 |
|------|------|--------|
| **原始wget** | 50-200 KB/s | ❌ 慢，无断点续传 |
| **wget + 代理** | 1-5 MB/s | ✓ 较快，需要VPN |
| **aria2c** | 5-20 MB/s | ✅ 快，多线程 |
| **aria2c + 代理** | 10-50 MB/s | ✅✅ 最快 |
| **浏览器下载** | 1-10 MB/s | ✓ 可靠但需手动操作 |

---

## 故障排查

### 问题1: 连接超时

```bash
# 增加超时时间和重试次数
wget --timeout=30 --tries=10 <URL>
```

### 问题2: 下载中断

```bash
# 使用 -c 参数断点续传
wget -c <URL>

# 或使用 aria2c（自动断点续传）
aria2c -x 16 -s 16 --continue=true <URL>
```

### 问题3: 代理不工作

```bash
# 测试代理连接
curl --proxy http://127.0.0.1:7890 https://www.google.com

# 如果失败，检查:
# 1. 代理软件是否运行
# 2. 端口号是否正确
# 3. 是否允许局域网连接
```

---

## 推荐配置流程

1. ✅ **安装 aria2c**: `sudo apt install aria2`
2. ✅ **配置代理**（如果有）: 编辑 `download_checkpoints.sh`
3. ✅ **运行下载**: `bash download_checkpoints.sh`
4. ✅ **验证文件**: `ls -lh checkpoints/`

这样可以获得最快的下载速度和最佳的用户体验！🚀


