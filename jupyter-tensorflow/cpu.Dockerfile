FROM ghcr.io/pluralsh/kubeflow-notebooks-jupyter:2.10.1

USER root

# update - ensure apt packages are always updated
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

 USER $NB_UID

# install - requirements.txt
COPY --chown=jovyan:users cpu-requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --constraint /protected-packages.txt -r /tmp/requirements.txt --quiet --no-cache-dir \
 && cat /tmp/requirements.txt >> /protected-packages.txt \
 && rm -f /tmp/requirements.txt
