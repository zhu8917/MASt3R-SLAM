#!/bin/bash
# MASt3R-SLAM 运行脚本 (RTX 5080 JIT 支持)
export TORCH_CUDA_ARCH_LIST="9.0+PTX"
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
python main.py "$@"
