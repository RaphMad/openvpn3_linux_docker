FROM debian

# Taken from https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux
RUN apt-get update && \
    apt-get install --no-install-recommends -y apt-transport-https ca-certificates curl gnupg

RUN curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | \
    gpg --dearmor > /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg && \
    curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-bullseye.list \
    > /etc/apt/sources.list.d/openvpn3.list && \
    apt update && \
    apt install --no-install-recommends -y openvpn3
