# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:20.04 as base

SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ENV ASDF_DIR "/asdf"
ENV ASDF_DATA_DIR $ASDF_DIR
ENV PATH $ASDF_DIR/shims:$ASDF_DIR/bin:$PATH

ENV TZ Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY <<EOF packages
build-essential
ca-certificates
curl
git
wget
coreutils
dirmngr
gpg
libbz2-dev
libffi-dev
liblzma-dev
libncurses5-dev
libreadline-dev
libsqlite3-dev
libssl-dev
libxml2-dev
libxmlsec1-dev
libxtst6
llvm
locales
tk-dev
xz-utils
zlib1g-dev
EOF

RUN <<EOF
apt update
apt install -y --no-install-recommends $(cat packages)
git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR
apt-get clean
apt-get autoremove -y
cd $ASDF_DIR
git checkout "$(git describe --abbrev=0 --tags)"
rm -rf /var/lib/apt/lists/*
EOF

FROM base as python
COPY <<EOF /root/.default-python-packages
poetry
ptipython
requests
pre-commit
mypy
EOF

RUN asdf plugin add python
RUN asdf install python latest
RUN asdf global python latest
RUN asdf install python 3.7.12
RUN asdf install python 3.9.10
RUN asdf install python 3.11.0a4
RUN find . -name '__pycache__' | xargs rm -rf

FROM base as golang
RUN asdf plugin add golang
RUN asdf install golang latest
RUN asdf install golang 1.18beta2
RUN asdf global golang 1.18beta2

FROM base as final
COPY --from=golang $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=golang /root/.tool-versions /root/.tool-versions-golang

COPY --from=python $ASDF_DATA_DIR $ASDF_DATA_DIR
COPY --from=python /root/.tool-versions /root/.tool-versions-python

RUN cat /root/.tool-versions-* > /root/.tool-versions \
    && rm -f /root/.tool-versions-* \
    && asdf reshim
