# [openvpn3_linux_docker](https://github.com/RaphMad/openvpn3_linux_docker)

This is a containerized version of [openvpn3-linux](https://github.com/OpenVPN/openvpn3-linux)

It can be used to provide VPN access to other containers (see example compose file below).
In addition, a "killswitch"-type set of firewall rules prevent any outgoing traffic from not traversing the VPN tunnel.

Note that this container aims to be as simple as possible - configuration can be provided via environment variables, but the defaults should be sensible for most common VPN configuration files.
The only required part is the configuration file itself, which by default is expected to be mounted under `/config.ovpn` and the environment variable `VPN_HOST`, which will be used to generate a firewall exclusion for the initial DNS lookup of your VPN server.

## Environment variables

| Name                   | Description                                                                                                                                 |
| :----:                 | :----: |
| `VPN_HOST`             | Hostname of the VPN endpoint (server) to connect to. Required if your configuration specifies the host by name and firewall rules are used. |
| `ENABLE_DCO`           | Set to true to enable DCO if your kernel supports it. Optional |
| `VPN_EXTERNAL_IP`      | If your VPN provides a static external IP, you can set it via this variable to regularly verify your external IP in the healthcheck. Optional |
| `DISABLE_FIREWALL`     | Set to true to disable the creation of firewall rules. Optional (Firewall rules are enabled by default) |
| `VPN_PROTO`            | Modify if your VPN configuration uses `tcp` instead of `udp`. Optional (Default `udp`) |
| `VPN_PORT`             | Modify if your VPN configuration uses a port different from the default `1194`. Optional (Default `1194`) |


## Expected bind mounts

| Name                   | Description                                                                                                                                 |
| :----:                 | :----: |
| `/config.ovpn`         | OpenVPN configuration file. |


## Minimal `docker-compose.yml`

```yaml
version: '3.9'

services:
  openvpn:
    image: raphmad/openvpn3_linux
    container_name: openvpn
    restart: unless-stopped
    privileged: true
    environment:
      VPN_HOST: <some.host>
    volumes:
      - <host_path_to_config.ovpn>:/config.ovpn:ro

  some_service:
    image: alpine
    container_name: some_service
    restart: unless-stopped
    network_mode: service:openvpn
    entrypoint: ["sleep", "infinity"]
    depends_on:
      - openvpn
```

## Extended / annotated `docker-compose.yml`

```yaml
version: '3.9'

services:
  openvpn:
    image: raphmad/openvpn3_linux
    container_name: openvpn
    restart: unless-stopped
    # It is a good practice to make containers read-only whenever possible and mount a tmpfs only for locations that need writing during runtime.
    read_only: true
    tmpfs:
      - /run/
      - /var/run/dbus/
    # For now this seems required by the design of OpenVPN, but `CAP_NET_ADMIN` should be enough to run unprivileged in the future.
    privileged: true
    # Set this if your VPN provides IPv6 access (and you want to use it).
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
    # Your locally configured nameservers may not be accessible through the VPN tunnel.
    # Some VPN providers will "push" their DNS servers to you, but as a fallback you can always just configure one thats guaranteed to work from the VPN endpoint.
    dns:
      - 1.1.1.1
    environment:
      VPN_HOST: <some.host>
      # Setting the _expected_ external IP will verify it in the healthcheck of the VPN container.
      VPN_EXTERNAL_IP: <1.2.3.4>
      # This is an experimental feature, but feel free to use it if your kernel has support for it.
      ENABLE_DCO: 'true'
    volumes:
      - <host_path_to_config.ovpn>:/config.ovpn:ro

  some_service:
    image: alpine
    container_name: some_service
    restart: unless-stopped
    network_mode: service:openvpn
    entrypoint: ["sleep", "infinity"]
    depends_on:
      - openvpn
```
