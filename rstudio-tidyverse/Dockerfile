FROM ghcr.io/pluralsh/kubeflow-notebooks-rstudio:4.0.5

# args - software versions
 # renovate: datasource=conda depName=conda-forge/r-tidyverse versioning=semver
ARG R_TIDYVERSE_VERSION=2.0.0

# switch to root user for conda installation
# (only necessary when installing r-tidyverse with Kaniko)
USER root

# update - ensure apt packages are always updated
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install - r-tidyverse
RUN conda install -y -q \
    r-tidyverse=${R_TIDYVERSE_VERSION} \
 && conda update -y -q --all \
 && conda clean -a -f -y \
 && chown -R ${NB_USER}:users ${CONDA_DIR} \
 && chown -R ${NB_USER}:users ${HOME}

USER ${NB_USER}
