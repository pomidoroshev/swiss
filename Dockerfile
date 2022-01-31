# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV TZ Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY <<EOF packages
apt-transport-https
bash-completion
brotli
chrony
curl
ffmpeg
g++
gcc
git
gnupg2
htop
jq
make
mc
mlocate
libreadline-dev
sqlite3
tmux
tree
vim
wget
zlib1g
zlib1g-dev
bzip2
libbz2-dev
openssl
libssl-dev
mlocate
sudo
libsqlite3-dev
libffi-dev
software-properties-common
gawk
autoconf
automake
bison
libgdbm-dev
libncurses5-dev
libtool
libyaml-dev
pkg-config
libgmp-dev
re2c
libxml2-dev
libcurl4-openssl-dev
libc-dev
dpkg
dpkg-dev
libgd-dev
libonig-dev
libpq-dev
libzip-dev
EOF

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt <<EOF
apt-get update
apt-get upgrade -y
apt-get install -y $(cat packages)
EOF

ARG UNAME=swiss
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME && echo "swiss:swiss" | chpasswd && adduser $UNAME sudo

WORKDIR /home/$UNAME
USER $UNAME

ENV HOME /home/$UNAME
ENV PATH $PATH:$HOME/.asdf/shims:$HOME/.asdf/bin

RUN <<EOF
git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc
echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile
echo 'legacy_version_file = yes' >> $HOME/.asdfrc
EOF

COPY <<EOF $HOME/.default-python-packages
poetry
ptipython
requests
pre-commit
mypy
EOF

ENV RUST_WITHOUT rust-docs,rust-other-component

RUN <<EOF
plugins=(
    golang
    python
    nodejs
    rust
    kotlin
    ruby
    nim
    zig
    php
)

global_versions=(
    "php latest"
    "ruby latest"
    "python latest"
    "golang latest"
    "java openjdk-17.0.2"
    "nodejs latest"
    "rust latest"
    "kotlin latest"
    "nim latest"
    "zig latest"
)

extra_versions=(
    "golang 1.18beta2"
    "python pypy3.8-7.3.7"
    "python 3.7.12"
    "python 3.8.12"
    "python 3.9.10"
    "python 3.11.0a4"
)

for plugin in "${plugins[@]}"
do
    asdf plugin add $plugin &
done
wait

for ver in "${global_versions[@]}"
do
    asdf install $ver &
done
wait

for ver in "${global_versions[@]}"
do
    asdf global $ver
done

for ver in "${extra_versions[@]}"
do
    asdf install $ver
done

asdf reshim
EOF
