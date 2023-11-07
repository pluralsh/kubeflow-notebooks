FROM ghcr.io/pluralsh/kubeflow-notebooks-codeserver:2.4.1

USER root

# args - software versions
ARG CODESERVER_PYTHON_VERSION=2023.20.0
ARG CODESERVER_GITLENS_VERSION=14.4.1
ARG CODESERVER_GIT_GRAPH_VERSION=1.30.0
ARG MINIFORGE_ARCH="x86_64"
 # renovate: datasource=github-tags depName=conda-forge/miniforge versioning=loose
ARG MINIFORGE_VERSION=23.3.1-1
 # renovate: datasource=conda depName=conda-forge/conda versioning=semver
ARG CONDA_VERSION=23.10.0
 # renovate: datasource=conda depName=conda-forge/mamba versioning=semver
ARG MAMBA_VERSION=1.5.3
 # renovate: datasource=conda depName=conda-forge/pip versioning=semver
ARG PIP_VERSION=23.3.1
 # renovate: datasource=conda depName=conda-forge/python versioning=semver
ARG PYTHON_VERSION=3.12.0

# update - ensure apt packages are always updated
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# setup environment for conda
ENV CONDA_DIR /opt/conda
ENV PATH "${CONDA_DIR}/bin:${PATH}"
RUN mkdir -p ${CONDA_DIR} \
 && echo ". /opt/conda/etc/profile.d/conda.sh" >> ${HOME}/.bashrc \
 && echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/profile \
 && echo "conda activate base" >> ${HOME}/.bashrc \
 && echo "conda activate base" >> /etc/profile \
 && echo "mamba activate base" >> ${HOME}/.bashrc \
 && echo "mamba activate base" >> /etc/profile \
 && chown -R ${NB_USER}:users ${CONDA_DIR} \
 && chown -R ${NB_USER}:users ${HOME}

USER $NB_UID

# install - conda, pip, python
RUN curl -sL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${MINIFORGE_ARCH}.sh" -o /tmp/Miniforge3.sh \
 && curl -sL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${MINIFORGE_ARCH}.sh.sha256" -o /tmp/Miniforge3.sh.sha256 \
 && echo "$(cat /tmp/Miniforge3.sh.sha256 | awk '{ print $1; }') /tmp/Miniforge3.sh" | sha256sum --check \
 && rm /tmp/Miniforge3.sh.sha256 \
 && /bin/bash /tmp/Miniforge3.sh -b -f -p ${CONDA_DIR} \
 && rm /tmp/Miniforge3.sh \
 && conda config --system --set auto_update_conda false \
 && conda config --system --set show_channel_urls true \
 && mamba install -y -q \
    python=${PYTHON_VERSION} \
    conda=${CONDA_VERSION} \
    pip=${PIP_VERSION} \
    mamba=${MAMBA_VERSION} \
 && echo "conda ${CONDA_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "mamba ${MAMBA_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "python ${PYTHON_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "pip ${PIP_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && mamba update -y -q --all \
 && mamba clean -a -f -y \
 && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
 && find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete \
 && chown -R ${NB_USER}:users ${CONDA_DIR} \
 && chown -R ${NB_USER}:users ${HOME}

# install - codeserver extensions
RUN code-server --install-extension "ms-python.python@${CODESERVER_PYTHON_VERSION}" \
 && code-server --install-extension "eamodio.gitlens@${CODESERVER_GITLENS_VERSION}" \
 && code-server --install-extension "mhutchie.git-graph@${CODESERVER_GIT_GRAPH_VERSION}"

# s6 - copy scripts
COPY --chown=jovyan:users s6/ /etc

# s6 - 01-copy-tmp-home
USER root
RUN mkdir -p /tmp_home \
 && cp -r ${HOME} /tmp_home \
 && chown -R ${NB_USER}:users /tmp_home
USER ${NB_UID}
