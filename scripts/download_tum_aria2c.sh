#!/bin/bash
# TUM RGB-D Dataset 下载脚本 (使用 aria2c 多线程加速)

set -e

echo "================================================"
echo "使用 aria2c 下载 TUM RGB-D Dataset"
echo "================================================"

# 检查 aria2c 是否安装
if ! command -v aria2c &> /dev/null; then
    echo "❌ 错误: aria2c 未安装"
    echo "请先安装: sudo apt install aria2"
    exit 1
fi

# 创建下载目录
mkdir -p datasets/tum
cd datasets/tum

# aria2c 下载配置
# -x 16: 最多使用16个连接
# -s 16: 将文件分成16段下载
# -k 1M: 每段最小1MB
# --continue=true: 自动断点续传
ARIA2C_OPTS="-x 16 -s 16 -k 1M --continue=true --max-connection-per-server=16"

echo ""
echo "开始下载数据集..."
echo ""

# 下载所有数据集
echo "下载 freiburg1_360..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_360.tgz

echo "下载 freiburg1_floor..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_floor.tgz

echo "下载 freiburg1_desk..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_desk.tgz

echo "下载 freiburg1_desk2..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_desk2.tgz

echo "下载 freiburg1_room..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_room.tgz

echo "下载 freiburg1_plant..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_plant.tgz

echo "下载 freiburg1_teddy..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_teddy.tgz

echo "下载 freiburg1_xyz..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_xyz.tgz

echo "下载 freiburg1_rpy..."
aria2c $ARIA2C_OPTS https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_rpy.tgz

echo ""
echo "================================================"
echo "下载完成，开始解压..."
echo "================================================"
echo ""

# 解压所有数据集
tar -xvzf rgbd_dataset_freiburg1_360.tgz
tar -xvzf rgbd_dataset_freiburg1_floor.tgz
tar -xvzf rgbd_dataset_freiburg1_desk.tgz
tar -xvzf rgbd_dataset_freiburg1_desk2.tgz
tar -xvzf rgbd_dataset_freiburg1_room.tgz
tar -xvzf rgbd_dataset_freiburg1_plant.tgz
tar -xvzf rgbd_dataset_freiburg1_teddy.tgz
tar -xvzf rgbd_dataset_freiburg1_xyz.tgz
tar -xvzf rgbd_dataset_freiburg1_rpy.tgz

echo ""
echo "================================================"
echo "✓ TUM RGB-D 数据集下载并解压完成！"
echo "================================================"
echo "数据集位置: $(pwd)"
echo ""
ls -lh

