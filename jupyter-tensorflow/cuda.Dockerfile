FROM ghcr.io/pluralsh/kubeflow-notebooks-jupyter:2.5.0

USER root

# get versions from https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/
# args - software versions
ARG CUDA_VERSION=11.8
ARG CUDA_COMPAT_VERSION=520.61.05-1
ARG CUDA_CUDART_VERSION=11.8.89-1
ARG CUDNN_VERSION=8.8.0.121-1
ARG LIBNVINFER_VERSION=8.5.3-1
ARG LIBNCCL_VERSION=2.15.5-1
ARG LIBCUBLAS_VERSION=11.11.3.6-1

# we need bash's env var character substitution
SHELL ["/bin/bash", "-c"]

# install - cuda
# for `cuda-compat-*`: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN curl -sL "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub" | apt-key add - \
 && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" > /etc/apt/sources.list.d/cuda.list \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get -yq install --no-install-recommends \
    cuda-compat-${CUDA_VERSION/./-}=${CUDA_COMPAT_VERSION} \
    cuda-cudart-${CUDA_VERSION/./-}=${CUDA_CUDART_VERSION} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/local/cuda-${CUDA_VERSION} /usr/local/cuda

# envs - cuda
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=${CUDA_VERSION}"

# install - other nvidia stuff
RUN apt-get -yq update \
 && apt-get -yq install --no-install-recommends \
    cm-super \
    cuda-command-line-tools-${CUDA_VERSION/./-} \
    cuda-nvrtc-${CUDA_VERSION/./-} \
    libcublas-${CUDA_VERSION/./-}=${LIBCUBLAS_VERSION} \
    libcudnn8=${CUDNN_VERSION}+cuda${CUDA_VERSION} \
    libcufft-${CUDA_VERSION/./-} \
    libcurand-${CUDA_VERSION/./-} \
    libcusolver-${CUDA_VERSION/./-} \
    libcusparse-${CUDA_VERSION/./-} \
    cuda-nvcc-${CUDA_VERSION/./-} \
    cuda-cupti-${CUDA_VERSION/./-} \
    cuda-nvprune-${CUDA_VERSION/./-} \
    cuda-libraries-${CUDA_VERSION/./-} \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libnccl2=${LIBNCCL_VERSION}+cuda${CUDA_VERSION} \
    libnvinfer8=${LIBNVINFER_VERSION}+cuda${CUDA_VERSION} \
    libnvinfer-plugin8=${LIBNVINFER_VERSION}+cuda${CUDA_VERSION} \
    libzmq3-dev \
    pkg-config \
    python3-libnvinfer=${LIBNVINFER_VERSION}+cuda${CUDA_VERSION} \
    libnvparsers8=${LIBNVINFER_VERSION}+cuda${CUDA_VERSION} \
    libnvonnxparsers8=${LIBNVINFER_VERSION}+cuda${CUDA_VERSION} \
 && apt-mark hold \
    libcublas-${CUDA_VERSION/./-} \
    libnccl2 \
    libcudnn8 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# tensorflow fix - some tensorflow tools expect a `python` binary
RUN ln -s $(which python3) /usr/local/bin/python

USER $NB_UID

# install - requirements.txt
COPY --chown=jovyan:users cuda-requirements.txt /tmp/requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt --quiet --no-cache-dir \
 && rm -f /tmp/requirements.txt
