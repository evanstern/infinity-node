WireGuard vm-104 config templates (no secrets).

Deployment pattern (example):
- Clone repo to `/opt/infinity-node` on vm-104.
- Symlink templates into place, then fill placeholders with real keys:
  - `/etc/wireguard/wg0.conf -> /opt/infinity-node/config/wireguard/vm-104/wg0.conf`
  - `/etc/nftables.d/wg-allow.nft -> /opt/infinity-node/config/wireguard/vm-104/nftables/wg-allow.nft`
  - `/etc/nftables.d/wg-allow-nuke.nft -> /opt/infinity-node/config/wireguard/vm-104/nftables/wg-allow-nuke.nft`
  - `/etc/sysctl.d/99-wg.conf -> /opt/infinity-node/config/wireguard/vm-104/sysctl/99-wg.conf`
  - `/etc/netplan/50-cloud-init.yaml -> /opt/infinity-node/config/wireguard/vm-104/netplan/50-cloud-init.yaml`

Placeholders:
- SERVER_PRIVATE_KEY, SERVER_PUBLIC_KEY
- LAPTOP_PUBLIC_KEY, PHONE_PUBLIC_KEY
- ENDPOINT_HOST (public IP or DNS), LISTEN_PORT (default 51820)
- DNS_SERVER (e.g., 192.168.1.1)

Key generation happens on vm-104; never store private keys in git.

Netplan: template sets static IP `192.168.1.104/24` on `ens18` with gateway `192.168.1.1` and DNS servers `192.168.1.79, 192.168.1.1, 8.8.8.8`. Adjust interface name if different.
