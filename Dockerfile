FROM alpine AS builder

RUN apk add --no-cache autoconf \
                       automake \
                       g++ \
                       git \
                       glib-dev \
                       jsoncpp-dev \
                       libcap-ng-dev \
                       libnl3-dev \
                       lz4-dev \
                       make \
                       openssl-dev \
                       pkgconfig \
                       protobuf-dev \
                       tinyxml2-dev

RUN git clone --depth 1 --single-branch https://github.com/OpenVPN/openvpn3-linux.git
RUN cd openvpn3-linux && \
    ./bootstrap.sh && \
    ./configure --enable-dco --disable-addons-aws --disable-bash-completion && \
    ./make


FROM scratch

COPY --from=builder /openvpn3 /openvpn3
