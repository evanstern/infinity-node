# Traefik Base Template

This directory contains base templates for deploying Traefik reverse proxy across all VMs in the infinity-node infrastructure.

## Structure

```
stacks/traefik/
├── template/              # Base templates (this directory)
│   ├── docker-compose.yml.template
│   ├── traefik.yml.template
│   ├── dynamic.yml.template
│   └── README.md
└── vm-XXX/               # VM-specific deployments
    ├── docker-compose.yml
    ├── traefik.yml
    ├── dynamic.yml
    └── README.md
```

## Purpose

These templates provide a reusable foundation for deploying Traefik on each VM. Each VM gets its own directory (`vm-XXX/`) with VM-specific configuration files derived from these templates.

## Files

### `docker-compose.yml.template`

Base Docker Compose configuration for Traefik container:
- Uses Traefik v3.0 image
- Exposes ports 80 (HTTP) and 443 (HTTPS)
- Mounts configuration files
- Sets up Docker network for service communication
- Includes health check

### `traefik.yml.template`

Static Traefik configuration:
- Defines entrypoints (web on port 80, websecure on port 443)
- Configures file provider for dynamic routing rules
- Enables Docker provider (optional, for future label-based routing)
- Sets up API dashboard (insecure for now)
- Configures logging

### `dynamic.yml.template`

Dynamic routing rules template:
- Contains routers (how requests are matched)
- Contains services (backend servers to route to)
- Contains middlewares (request/response transformations)
- This file is customized per VM with actual service routes

## Usage

### Creating a VM-Specific Deployment

1. **Copy templates to VM directory:**
   ```bash
   cp stacks/traefik/template/* stacks/traefik/vm-XXX/
   ```

2. **Rename template files:**
   ```bash
   cd stacks/traefik/vm-XXX/
   mv docker-compose.yml.template docker-compose.yml
   mv traefik.yml.template traefik.yml
   mv dynamic.yml.template dynamic.yml
   ```

3. **Customize `docker-compose.yml`:**
   - Update network name if needed (default: `traefik-network`)
   - Adjust volume paths if needed
   - Add environment variables if needed

4. **Customize `traefik.yml`:**
   - Usually no changes needed (static config is VM-agnostic)
   - Can adjust logging level if needed

5. **Customize `dynamic.yml`:**
   - Add routers for each service on this VM
   - Add services pointing to backend containers
   - Use DNS names from `config/dns-records.json`
   - Format: `service-name.local.infinity-node.com`

### Example Service Route

```yaml
http:
  routers:
    vaultwarden:
      rule: "Host(`vaultwarden.local.infinity-node.com`)"
      entryPoints:
        - websecure
      service: vaultwarden

  services:
    vaultwarden:
      loadBalancer:
        servers:
          - url: "http://vaultwarden:80"
```

## Network Considerations

### Standard Bridge Network (Most Services)

Most services use standard Docker bridge networks. Traefik can route to them directly:

```yaml
services:
  service-name:
    loadBalancer:
      servers:
        - url: "http://container-name:port"
```

### Host Network Mode (Emby on VM 100)

Services using `network_mode: host` cannot be routed via Traefik's Docker network. Options:
1. **Keep direct access** (recommended for performance)
2. **Route via host IP** (more complex, may impact performance)

### VPN Container Network Mode (VM 101)

Services using `network_mode: container:vpn` share the VPN container's network. Traefik can route to the VPN container's exposed ports:

```yaml
services:
  deluge:
    loadBalancer:
      servers:
        - url: "http://vpn:8112"  # VPN container exposes port 8112
```

## Deployment

See `stacks/traefik/README.md` for deployment instructions.

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[config/dns-records.json|DNS Records Configuration]]
- [[docs/agents/DOCKER|Docker Agent]]
