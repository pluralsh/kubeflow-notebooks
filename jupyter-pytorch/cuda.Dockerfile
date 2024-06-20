FROM ghcr.io/pluralsh/kubeflow-notebooks-jupyter:3.2.4

USER root

# nvidia configs
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# update - ensure apt packages are always updated
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

 USER $NB_UID

# install - requirements.txt
COPY --chown=jovyan:users cuda-requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --constraint /protected-packages.txt -r /tmp/requirements.txt --quiet --no-cache-dir \
 && cat /tmp/requirements.txt >> /protected-packages.txt \
 && rm -f /tmp/requirements.txt
