#!/usr/bin/env sh

pip install cython
apt-get update && apt-get install -y \
g++ make binutils autoconf automake autotools-dev \
libtool pkg-config zlib1g-dev libcunit1-dev libssl-dev \
libxml2-dev libev-dev libevent-dev libjansson-dev \
libc-ares-dev libjemalloc-dev \
&& rm -rf /var/lib/apt/lists/*
git clone https://github.com/nghttp2/nghttp2
cd nghttp2
git submodule update --init
autoreconf -i
automake
autoconf
./configure
make
make install
