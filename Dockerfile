# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:20.04 as base

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

RUN <<EOF
apt-get update
apt-get upgrade -y
apt-get install -y $(cat packages)
EOF

ENV ASDF_DIR "/asdf"
ENV ASDF_DATA_DIR $ASDF_DIR
ENV PATH $ASDF_DIR/shims:$ASDF_DIR/bin:$PATH
ENV V latest

RUN <<EOF
git clone --depth 1 https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v0.9.0
echo 'legacy_version_file = yes' >> /root/.asdfrc
EOF

FROM base as python
COPY <<EOF /root/.default-python-packages
poetry
ptipython
requests
pre-commit
mypy
EOF

ENV P python
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN asdf install $P pypy3.8-7.3.7
RUN asdf install $P 3.7.12
RUN asdf install $P 3.8.12
RUN asdf install $P 3.9.10
RUN asdf install $P 3.11.0a4

FROM base as golang
ENV P golang
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V
RUN asdf install $P 1.18beta2

FROM base as nodejs
ENV P nodejs
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as rust
ENV RUST_WITHOUT rust-docs,rust-other-component
ENV P=rust
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as kotlin
ENV P kotlin
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as ruby
ENV P ruby
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as nim
ENV P nim
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as zig
ENV P zig
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as php
ENV P php
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as java
ENV P java
RUN asdf plugin add $P && asdf install $P openjdk-17.0.2 && asdf global $P openjdk-17.0.2

# NB
FROM java as scala
ENV P scala
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as dotnet-core
ENV P dotnet-core
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as crystal
ENV P crystal
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as dart
ENV P dart
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as deno
ENV P deno
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as elm
ENV P elm
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as elixir
ENV P elixir
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as haskell
ENV P haskell
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as julia
ENV P julia
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as lua
ENV P lua
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as luajit
ENV P luaJIT
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as ocaml
ENV P ocaml
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as r
ENV P R
RUN asdf plugin add $P && asdf install $P $V && asdf global $P $V

FROM base as final
COPY --from=golang $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=golang /root/.tool-versions /root/.tool-versions-golang

COPY --from=nodejs $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=nodejs /root/.tool-versions /root/.tool-versions-nodejs

COPY --from=python $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=python /root/.tool-versions /root/.tool-versions-python

COPY --from=rust $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=rust /root/.tool-versions /root/.tool-versions-rust

COPY --from=kotlin $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=kotlin /root/.tool-versions /root/.tool-versions-kotlin

COPY --from=ruby $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=ruby /root/.tool-versions /root/.tool-versions-ruby

COPY --from=nim $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=nim /root/.tool-versions /root/.tool-versions-nim

COPY --from=zig $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=zig /root/.tool-versions /root/.tool-versions-zig

COPY --from=php $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=php /root/.tool-versions /root/.tool-versions-php

COPY --from=java $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=java /root/.tool-versions /root/.tool-versions-java

COPY --from=dotnet-core $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=dotnet-core /root/.tool-versions /root/.tool-versions-dotnet-core

COPY --from=crystal $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=crystal /root/.tool-versions /root/.tool-versions-crystal

COPY --from=dart $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=dart /root/.tool-versions /root/.tool-versions-dart

COPY --from=deno $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=deno /root/.tool-versions /root/.tool-versions-deno

COPY --from=elm $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=elm /root/.tool-versions /root/.tool-versions-elm

COPY --from=elixir $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=elixir /root/.tool-versions /root/.tool-versions-elixir

COPY --from=haskell $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=haskell /root/.tool-versions /root/.tool-versions-haskell

COPY --from=julia $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=julia /root/.tool-versions /root/.tool-versions-julia

COPY --from=lua $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=lua /root/.tool-versions /root/.tool-versions-lua

COPY --from=luajit $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=luajit /root/.tool-versions /root/.tool-versions-luajit

COPY --from=ocaml $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=ocaml /root/.tool-versions /root/.tool-versions-ocaml

COPY --from=r $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=r /root/.tool-versions /root/.tool-versions-r

COPY --from=scala $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=scala /root/.tool-versions /root/.tool-versions-scala

RUN cat /root/.tool-versions-* > /root/.tool-versions \
    && rm -f /root/.tool-versions-* \
    && asdf reshim
