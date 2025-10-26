---
type: stack
service: newt
category: networking
vms: [103]
priority: critical
status: running
stack-type: single-container
has-secrets: true
external-access: true
ports: []
backup-priority: low
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-103
  - networking
  - tunnel
  - pangolin
  - single-container
  - has-secrets
  - external-access
aliases:
  - Newt
  - Pangolin Client
  - Tunnel Client
---

# Newt Stack

**Service:** Newt (Pangolin Tunnel Client)
**VM:** 103 (misc)
**Priority:** Critical - Provides external access to services
**Image:** `fosrl/newt:latest`

## Overview

Newt is a Pangolin tunnel client that establishes secure tunnels to expose services externally without requiring port forwarding or firewall changes. It connects to the Pangolin server at `https://pangolin.infinity-node.com` to provide external access to services on this VM.

## Key Features

- **Secure Tunneling:** Encrypted tunnels for external service access
- **No Port Forwarding:** Works behind NAT/firewalls
- **Automatic Reconnection:** Maintains persistent connection
- **Zero Configuration Firewall:** No inbound port requirements
- **Multiple Services:** Can expose multiple services via single tunnel

## Configuration

### Secrets

**Required secrets stored in Vaultwarden:**

1. **NEWT_ID** - Newt client identifier
   - Location: `infinity-node/vm-103-misc/newt-credentials`
   - Field: `newt_id`
   - Current value: `ihf68v2l8edj4p3`

2. **NEWT_SECRET** - Newt client authentication secret
   - Location: `infinity-node/vm-103-misc/newt-credentials`
   - Field: `newt_secret`
   - Current value: `vw25radqd2gtzp5qamw9x46k2olhyrgym21ugx18jck73ne5`

**Store in Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)

./scripts/create-secret.sh "newt-credentials" "vm-103-misc" "" \
  '{"service":"newt","vm":"103","newt_id":"ihf68v2l8edj4p3","newt_secret":"vw25radqd2gtzp5qamw9x46k2olhyrgym21ugx18jck73ne5"}'
```

**Retrieve from Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)

NEWT_ID=$(bw get item newt-credentials --field newt_id)
NEWT_SECRET=$(bw get item newt-credentials --field newt_secret)
```

### Environment Variables

- `PANGOLIN_ENDPOINT` - Pangolin server URL (default: `https://pangolin.infinity-node.com`)
- `NEWT_ID` - Client identifier (secret)
- `NEWT_SECRET` - Client authentication secret (secret)

## Deployment

```bash
cd stacks/newt
cp .env.example .env

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
NEWT_ID=$(bw get item newt-credentials --field newt_id)
NEWT_SECRET=$(bw get item newt-credentials --field newt_secret)

# Update .env file with actual values
# Or use deployment script:
# ./scripts/deploy-with-secrets.sh newt 192.168.86.249 /path/to/stacks/newt

docker compose up -d
```

## Monitoring

```bash
# View connection logs
docker logs -f newt

# Check connection status
docker ps | grep newt

# Test external access
curl https://pangolin.infinity-node.com
```

## Exposed Services

Services exposed via this Pangolin tunnel (on VM 103):
- **Audiobookshelf** - https://pangolin.infinity-node.com/audiobookshelf
- **Vaultwarden** - https://vaultwarden.infinity-node.com
- **Paperless-NGX** - https://pangolin.infinity-node.com/paperless
- *Other services as configured*

## Troubleshooting

**Tunnel not connecting:**
- Check logs: `docker logs newt`
- Verify NEWT_ID and NEWT_SECRET are correct
- Ensure PANGOLIN_ENDPOINT is accessible
- Check network connectivity from container

**External access not working:**
- Verify tunnel is established (check logs)
- Confirm service is running locally
- Check Pangolin server configuration
- Verify DNS resolution for pangolin.infinity-node.com

**Connection drops frequently:**
- Check network stability
- Review Pangolin server logs
- Consider network timeout settings

## Security Considerations

- **Client Credentials:** NEWT_ID and NEWT_SECRET are authentication credentials
- **Encrypted Tunnel:** All traffic through tunnel is encrypted
- **No Inbound Ports:** No firewall rules required on VM
- **Credential Rotation:** Rotate credentials periodically
- **Access Control:** Managed via Pangolin server configuration

## Architecture

```
Internet
  ↓
pangolin.infinity-node.com (Pangolin Server)
  ↓ (encrypted tunnel)
Newt Client (this container)
  ↓ (local network)
Services on VM 103
```

## Dependencies

- **Pangolin Server:** Must be running and accessible
- **Network Access:** Outbound HTTPS access required
- **Services:** Local services that need external exposure

## Related Documentation

- [Pangolin Documentation](https://github.com/fosrl/pangolin)
- [Newt Client](https://github.com/fosrl/newt)
- Pangolin server configuration (separate VM or service)

## Notes

- Originally deployed alongside audiobookshelf (now separated for cleaner organization)
- Credentials were hardcoded in original compose file (now managed via Vaultwarden)
- Multiple newt instances can run on different VMs for exposing services
- Pangolin server manages routing and SSL termination
- Consider using separate newt instances per service for isolation
- External domain: https://pangolin.infinity-node.com
