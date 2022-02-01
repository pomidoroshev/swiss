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
gfortran
xorg-dev
libpcre2-dev
EOF

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt <<EOF
apt-get update
apt-get upgrade -y
apt-get install -y $(cat packages)
EOF

ENV ASDF_DIR "/asdf"
ENV ASDF_DATA_DIR $ASDF_DIR
ENV PATH $ASDF_DIR/shims:$ASDF_DIR/bin:$PATH

RUN <<EOF
git clone --depth 1 https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v0.9.0
echo 'legacy_version_file = yes' >> /root/.asdfrc
EOF

COPY <<EOF /root/.default-python-packages
poetry
ptipython
requests
pre-commit
mypy
EOF

ENV RUST_WITHOUT rust-docs,rust-other-component
RUN P=golang V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=python V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=nodejs V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=rust V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=kotlin V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=ruby V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=nim V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=zig V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=php V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=java V=openjdk-17.0.2 asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=dotnet-core V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=crystal V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=dart V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=deno V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=elm V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=elixir V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=haskell V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=julia V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=lua V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=luaJIT V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=ocaml V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=R V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN P=scala V=latest asdf plugin add $P && asdf install $P $V && asdf global $P $V

RUN P=golang V=1.18beta2 asdf plugin add $P && asdf install $P $V && asdf global $P $V

RUN P=python V=pypy3.8-7.3.7 asdf plugin add $P && asdf install $P $V
RUN P=python V=3.7.12 asdf plugin add $P && asdf install $P $V
RUN P=python V=3.8.12 asdf plugin add $P && asdf install $P $V
RUN P=python V=3.9.10 asdf plugin add $P && asdf install $P $V
RUN P=python V=3.11.0a4 asdf plugin add $P && asdf install $P $V

RUN asdf reshim
