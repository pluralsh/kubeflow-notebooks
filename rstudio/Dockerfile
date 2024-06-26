FROM ghcr.io/pluralsh/kubeflow-notebooks-base:2.4.2

USER root

# args - software versions
ARG MINIFORGE_ARCH="x86_64"
 # renovate: datasource=github-tags depName=conda-forge/miniforge versioning=loose
ARG MINIFORGE_VERSION=24.3.0-0
 # renovate: datasource=conda depName=conda-forge/conda versioning=semver
ARG CONDA_VERSION=23.11.0
 # renovate: datasource=conda depName=conda-forge/mamba versioning=semver
ARG MAMBA_VERSION=1.5.6
 # renovate: datasource=conda depName=conda-forge/pip versioning=semver
ARG PIP_VERSION=23.3.2
 # renovate: datasource=conda depName=conda-forge/python versioning=semver
ARG PYTHON_VERSION=3.12.4
ARG RSTUDIO_ARCH="amd64"
 # renovate: datasource=github-tags depName=rstudio/rstudio versioning=loose
ARG RSTUDIO_VERSION=2024.04.2+764
 # renovate: datasource=conda depName=conda-forge/r-base versioning=semver
ARG R_BASE_VERSION=4.3.3
 # renovate: datasource=conda depName=conda-forge/r-reticulate versioning=semver
ARG R_RETICULATE_VERSION=1.36.1
 # renovate: datasource=conda depName=conda-forge/r-png versioning=loose
ARG R_PNG_VERSION=0.1_8

# install - binary rstudio dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get -yq install --no-install-recommends \
    dpkg-sig \
    gdebi-core \
    libapparmor1 \
    libc6 \
    libclang-dev \
    libedit2 \
    libpq5 \
    libssl-dev \
    psmisc \
    rrdtool \
    sudo \
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

# setup environment for R
ENV R_HOME ${CONDA_DIR}/lib/R

USER ${NB_UID}

# install - conda, pip, python, r-base
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
    r-base=${R_BASE_VERSION} \
    r-reticulate=${R_RETICULATE_VERSION} \
    r-png=${R_PNG_VERSION} \
 && echo "conda ${CONDA_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "mamba ${MAMBA_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "python ${PYTHON_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "r-base ${R_BASE_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "r-reticulate ${R_RETICULATE_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "r-png ${R_PNG_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && mamba update -y -q --all \
 && mamba clean -a -f -y \
 && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
 && find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete \
 && chown -R ${NB_USER}:users ${CONDA_DIR} \
 && chown -R ${NB_USER}:users ${HOME}

# set default CRAN repo to RSPM (it has pre-compiled R packages, increasing user install speed)
RUN echo 'options(repos=c(CRAN="https://packagemanager.rstudio.com/all/__linux__/jammy/latest"))' >> ${R_HOME}/etc/Rprofile.site \
 && echo 'options(HTTPUserAgent=sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' >> ${R_HOME}/etc/Rprofile.site

# R needs TZ set
ENV TZ Etc/UTC
RUN echo "TZ=${TZ}" >> ${R_HOME}/etc/Renviron.site

USER root

# install - rstudio-server
# Affero General Public License may apply to RStudio: https://www.gnu.org/licenses/agpl-3.0.en.html
RUN curl -sL "https://download2.rstudio.org/server/jammy/${RSTUDIO_ARCH}/rstudio-server-${RSTUDIO_VERSION/+/-}-${RSTUDIO_ARCH}.deb" -o /tmp/rstudio-server.deb \
 && gdebi --n --q /tmp/rstudio-server.deb \
 && rm -f /tmp/rstudio-server.deb \
    # use advisory file-locks to improve PVC support
 && echo "lock-type=advisory" > /etc/rstudio/file-locks \
    # allow kubeflow to display rstudio in an iframe
 && echo "www-frame-origin=same" >> /etc/rstudio/rserver.conf \
    # allows the non-root NB_USER to run rstudio
 && chown -R ${NB_USER}:users /etc/rstudio \
 && chown -R ${NB_USER}:users /run/rstudio-server* \
 && chown -R ${NB_USER}:users /usr/lib/rstudio-server \
 && chown -R ${NB_USER}:users /var/lib/rstudio-server

# tell rstudio to use conda python by setting `RETICULATE_PYTHON` with `--rsession-path=/opt/rsession.sh`
COPY --chown=jovyan:users rsession.sh /opt

# s6 - copy scripts
COPY --chown=jovyan:users s6/ /etc

# s6 - 01-copy-tmp-home
RUN mkdir -p /tmp_home \
 && cp -r ${HOME} /tmp_home \
 && chown -R ${NB_USER}:users /tmp_home

USER ${NB_UID}

EXPOSE 8888

ENTRYPOINT ["/init"]
