FROM debian:sid

ARG V2RAY_VERSION=v1.3.1
ARG SSRUST_VERSION=v1.14.0


COPY conf/ /conf
COPY entrypoint.sh /entrypoint.sh

ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex\
    && apt update -y \
    && apt install -y wget xz-utils qrencode nginx-light jq \
    && apt clean -y \
    && chmod +x /entrypoint.sh \
    && mkdir -p /etc/shadowsocks /ssbin /v2raybin /wwwroot \
    && wget -O- "https://github.com/shadowsocks/shadowsocks-rust/releases/download/${SSRUST_VERSION}/shadowsocks-${SSRUST_VERSION}.x86_64-unknown-linux-musl.tar.xz" | \
        tar Jx -C /ssbin \
    && wget -O- "https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_VERSION}.tar.gz" | \
        tar zx -C /v2raybin \
    && install /v2raybin/v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
    && rm -rf /v2raybin

CMD /entrypoint.sh
