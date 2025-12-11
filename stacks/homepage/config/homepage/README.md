# Homepage Configuration Files

This directory contains the YAML configuration files for the Homepage dashboard.

## Configuration Files

- **settings.yaml** - Theme, layout, and general settings
- **services.yaml** - All service widgets and links (19 services organized by VM)
- **bookmarks.yaml** - Infrastructure bookmarks (Portainer, Proxmox, NAS)
- **widgets.yaml** - Dashboard widgets (resources, search, etc.)

## Adding API Keys for Widgets

Several services support widgets that require API keys. To enable widgets:

### Emby
1. Access Emby web UI: http://emby.local.infinity-node.win:8096
2. Settings → API Keys
3. Generate or copy existing API key
4. Edit `services.yaml` → Replace `YOUR_EMBY_API_KEY_HERE` with actual key

### Radarr / Sonarr / Lidarr / Prowlarr
1. Access service web UI (e.g., http://radarr.local.infinity-node.win:7878)
2. Settings → General → API Key
3. Copy the API key
4. Edit `services.yaml` → Replace `YOUR_RADARR_API_KEY_HERE` (or Sonarr/Lidarr/Prowlarr) with actual key

### Jellyseerr
1. Access Jellyseerr web UI: http://jellyseerr.local.infinity-node.win:5055
2. Settings → General → API Key
3. Copy the API key
4. Edit `services.yaml` → Replace `YOUR_JELLYSEERR_API_KEY_HERE` with actual key

## Background Images

Wallpapers can be added to `images/backgrounds/` directory. To enable:

1. Copy wallpaper images to `images/backgrounds/`
2. Edit `settings.yaml` and uncomment/configure the `background:` line
3. For rotation, Homepage supports random selection from directory

## Deployment

Configuration files are deployed via Portainer Git integration:

1. Edit files locally in `stacks/homepage/config/homepage/`
2. Commit changes to git
3. Portainer will automatically pull and redeploy
4. Restart Homepage container if needed: `docker restart homepage`

## File Structure

```
config/homepage/
├── settings.yaml      # Theme and layout
├── services.yaml      # Service widgets and links
├── bookmarks.yaml     # Infrastructure bookmarks
├── widgets.yaml       # Dashboard widgets
├── images/
│   └── backgrounds/   # Wallpaper images (optional)
└── README.md          # This file
```

## Notes

- API keys are stored in YAML files (not gitignored) - be careful not to commit sensitive keys
- Consider storing API keys in Vaultwarden and using environment variable substitution if Homepage supports it
- Widgets will show "No data" until API keys are configured
- Services without widgets will still show as clickable links
