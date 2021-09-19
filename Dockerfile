ARG BASE_CONTAINER=jupyter/datascience-notebook
ARG OWNER=melashri
FROM $BASE_CONTAINER
LABEL maintainer="Mohamed Elashri <elashrmr@mail.uc.edu>"

# Install Tensorflow
RUN mamba install --quiet --yes \
    'tensorflow' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"


# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
USER root

# System packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    vim \
    mercurial \
    subversion \
    cmake \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    gcc \
    g++ \
    nano

# Install Tex for nbconvert
RUN apt-get update && \
    apt-get install -y \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-latex-recommended 

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add RUN statements to install packages as the $NB_USER defined in the base images.

USER $NB_USER

# Add custom configuration
COPY config/ /home/$NB_USER/.jupyter/

# Install extensions
RUN jupyter labextension install @jupyterlab/git --no-build && \
    jupyter labextension install @jupyterlab/toc --no-build && \
    jupyter labextension install @ryantam626/jupyterlab_code_formatter --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter lab build --dev-build=False --minimize=False && \
    jupyter lab clean && \
    npm cache clean --force && \
    rm -rf $HOME/.node-gyp && \
    rm -rf $HOME/.local



# Install jupyter_tabnine
RUN pip3 install jupyter-tabnine --user && \
    jupyter nbextension install --py jupyter_tabnine --user && \
    jupyter nbextension enable --py jupyter_tabnine --user 



# Create folder
WORKDIR /workspace

# Start Notebook
CMD jupyter lab --allow-root

USER root