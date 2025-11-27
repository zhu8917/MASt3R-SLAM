from pathlib import Path
from setuptools import setup

import torch
from torch.utils.cpp_extension import BuildExtension, CppExtension
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
has_cuda = torch.cuda.is_available()

include_dirs = [
    os.path.join(ROOT, "mast3r_slam/backend/include"),
    os.path.join(ROOT, "thirdparty/eigen"),
]

sources = [
    "mast3r_slam/backend/src/gn.cpp",
]
extra_compile_args = {
    "cores": ["j8"],
    "cxx": ["-O3"],
}

if has_cuda:
    from torch.utils.cpp_extension import CUDAExtension

    sources.append("mast3r_slam/backend/src/gn_kernels.cu")
    sources.append("mast3r_slam/backend/src/matching_kernels.cu")
    extra_compile_args["nvcc"] = [
        "-O3",
        "-gencode=arch=compute_70,code=sm_70",   # V100
        "-gencode=arch=compute_75,code=sm_75",   # RTX 20 series
        "-gencode=arch=compute_80,code=sm_80",   # A100
        "-gencode=arch=compute_86,code=sm_86",   # RTX 30 series
        "-gencode=arch=compute_89,code=sm_89",   # RTX 40 series / Ada
        "-gencode=arch=compute_90,code=sm_90",   # H100 / Hopper
        "-gencode=arch=compute_120,code=sm_120", # RTX 50 series / Blackwell
    ]
    ext_modules = [
        CUDAExtension(
            "mast3r_slam_backends",
            include_dirs=include_dirs,
            sources=sources,
            extra_compile_args=extra_compile_args,
        )
    ]
else:
    print("CUDA not found, cannot compile backend!")

setup(
    ext_modules=ext_modules,
    cmdclass={"build_ext": BuildExtension},
)
