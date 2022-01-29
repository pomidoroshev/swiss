FROM ubuntu:20.04

RUN apt update && apt upgrade -y

ENV TZ Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt install -y \
    apt-transport-https \
    bash-completion \
    brotli \
    chrony \
    curl \
    ffmpeg \
    g++ \
    gcc \
    git \
    htop \
    jq \
    make \
    mc \
    mlocate \
    nim \
    libreadline-dev \
    sqlite3 \
    tmux \
    tree \
    vim \
    wget \
    zlib1g \
    zlib1g-dev \
    bzip2 \
    libbz2-dev \
    openssl \
    libssl-dev \
    mlocate \
    sudo \
    libsqlite3-dev \
    libffi-dev

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

RUN wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt update \
    && apt install -y dotnet-sdk-6.0

RUN useradd -m swiss && echo "swiss:swiss" | chpasswd && adduser swiss sudo

WORKDIR /home/swiss
USER swiss

RUN curl https://pyenv.run | bash

ENV HOME /home/swiss
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install 2.7.18 && \
    pyenv install 3.8.12 && \
    pyenv install 3.9.10 && \
    pyenv install 3.10.2 && \
    pyenv install 3.11.0a4 && \
    wait

RUN \
    PYENV_VERSION=2.7.18 pip install ptipython poetry pre-commit & \
    PYENV_VERSION=3.8.12 pip install ptipython poetry pre-commit & \
    PYENV_VERSION=3.9.10 pip install ptipython poetry pre-commit & \
    PYENV_VERSION=3.10.2 pip install ptipython poetry pre-commit & \
    PYENV_VERSION=3.11.0a4 pip install ptipython poetry pre-commit & \
    wait

RUN pyenv global 3.10.2


