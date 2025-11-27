# Copyright (C) 2022-present Naver Corporation. All rights reserved.
# Licensed under CC BY-NC-SA 4.0 (non-commercial use only).

from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension

# Use architectures compatible with CUDA 12.8
# RTX 5080 (Blackwell) requires sm_120 
all_cuda_archs = [
    '-gencode', 'arch=compute_70,code=sm_70',   # V100
    '-gencode', 'arch=compute_75,code=sm_75',   # RTX 20 series
    '-gencode', 'arch=compute_80,code=sm_80',   # A100
    '-gencode', 'arch=compute_86,code=sm_86',   # RTX 30 series
    '-gencode', 'arch=compute_89,code=sm_89',   # RTX 40 series / Ada
    '-gencode', 'arch=compute_90,code=sm_90',   # H100 / Hopper
    '-gencode', 'arch=compute_120,code=sm_120', # RTX 50 series / Blackwell
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
