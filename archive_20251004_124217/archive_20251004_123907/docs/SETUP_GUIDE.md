# Setup Guide

## Prerequisites

### Required Software
- **Roblox Studio**: Latest version from roblox.com
- **Rojo**: Version 7.5.1 (both CLI and Studio plugin)

### Rojo Installation

#### Install Rojo CLI
```bash
# Install via cargo (Rust package manager)
cargo install rojo

# Or download from GitHub releases
# https://github.com/rojo-rbx/rojo/releases/tag/v7.5.1
```

#### Install Rojo Studio Plugin
1. Open Roblox Studio
2. Go to PLUGINS tab
3. Search for "Rojo" in the toolbox
4. Install the Rojo plugin (ensure it's version 7.5.1)

### Verify Installation
```bash
# Check Rojo CLI version
rojo --version
# Should output: rojo 7.5.1

# Check plugin version in Studio
# Look for Rojo toolbar - should show v7.5.1
```

---

## Project Setup

### 1. Clone or Download Project
```bash
# If using git
git clone <repository-url>
cd Robot-Collectors-Rise-of-Gearhold

# Or download and extract ZIP file
```

### 2. Verify Project Structure
```
Robot-Collectors-Rise-of-Gearhold/
├── src/
│   ├── client/
│   │   └── init.client.luau
│   ├── server/
│   │   ├── init.server.luau
│   │   └── workspace-setup.server.luau
│   ├── server_modules/
│   │   ├── PlayerManager.luau
│   │   ├── RemoteSetup.luau
│   │   └── RobotManager.luau
│   └── shared/
├── docs/
├── default.project.json
└── Robot-Collectors.rbxlx
```

### 3. Start Rojo Server
```bash
# Navigate to project directory
cd Robot-Collectors-Rise-of-Gearhold

# Start the server
rojo serve --port 34877

# Expected output:
# Rojo server listening:
#   Address: localhost
#   Port:    34877
```

### 4. Open in Roblox Studio
1. Double-click `Robot-Collectors.rbxlx` to open in Studio
2. Or open Studio and File → Open → select the .rbxlx file

### 5. Connect Rojo Plugin
1. In Studio, look for the **Rojo** toolbar
2. Click **"Connect"**
3. Enter: `localhost:34877`
4. Click **"Connect"**
5. You should see scripts sync automatically

---

## Development Workflow

### Making Code Changes

1. **Edit Files**: Modify `.luau` files in the `src/` directory
2. **Auto-Sync**: Rojo automatically syncs changes to Studio
3. **Test**: Use Studio's Play button to test changes
4. **Debug**: Check Studio output for any errors

### Key Files to Edit

- **`src/server/init.server.luau`**: Modular server bootstrap and RemoteEvent handlers
- **`src/server_modules/`**: Server modules (`RemoteSetup`, `PlayerManager`, `RobotManager`) synced into `ServerScriptService/Modules`
- **`src/client/init.client.luau`**: UI, user interactions, visual updates
- **`src/server/workspace-setup.server.luau`**: World creation and environment

### Testing Changes

1. **Save** your changes in your code editor
2. **Wait** for Rojo sync (usually instant)
3. **Stop** the game in Studio (if running)
4. **Play** the game again to test changes

---

## Common Issues & Solutions

### Rojo Connection Issues

**Problem**: "Failed to connect to Rojo server"
**Solutions:**
- Ensure Rojo server is running (`rojo serve --port 34877`)
- Check port number matches (34877)
- Restart Rojo server if needed
- Verify firewall isn't blocking localhost connections

**Problem**: "Protocol version mismatch"
**Solutions:**
- Ensure both CLI and plugin are version 7.5.1
- Update plugin from Studio toolbox
- Reinstall Rojo CLI if needed

### Script Sync Issues

**Problem**: Changes not appearing in Studio
**Solutions:**
- Check Rojo server console for errors
- Verify file paths in `default.project.json`
- Restart Rojo server
- Disconnect and reconnect Rojo plugin

**Problem**: Scripts appearing in wrong locations
**Solutions:**
- Check `default.project.json` path mappings
- Ensure folder structure matches configuration
- Restart sync after fixing paths

### Game Runtime Issues

**Problem**: "leaderstats is not a valid member"
**Solutions:**
- Wait a moment after starting - leaderstats need time to create
- This error is harmless and resolves automatically

**Problem**: Robots not moving
**Solutions:**
- Check server console for movement debug output
- Ensure robots have BodyPosition and BodyVelocity
- Verify robot state is set to "auto_mining"

**Problem**: No mining zones visible
**Solutions:**
- Check that workspace-setup.server.luau is running
- Look for "Workspace setup complete" in console
- Restart the game to re-run workspace setup

---

## Performance Tips

### Optimizing Development

1. **Use Play Solo**: Faster than server testing for most changes
2. **Watch Console**: Monitor output for errors and debug info
3. **Save Frequently**: Rojo syncs on file save
4. **Minimize Background Apps**: Studio + Rojo can be resource intensive

### Debugging Techniques

1. **Print Statements**: Use `print()` for debugging (visible in output)
2. **Error Messages**: Check both client and server output windows
3. **Breakpoints**: Use Studio debugger for complex issues
4. **Network Tab**: Monitor RemoteEvent traffic

---

## Project Configuration

### Modifying Rojo Setup

**Changing Sync Port:**
```bash
# Use different port
rojo serve --port 8080

# Update connection in Studio plugin accordingly
```

**Adding New Folders:**
Edit `default.project.json`:
```json
{
  "tree": {
    "ReplicatedStorage": {
      "NewFolder": {
        "$path": "src/new-folder"
      }
    }
  }
}
```

### Environment Variables

**ROJO_PORT**: Set default port
```bash
export ROJO_PORT=34877
rojo serve  # Uses ROJO_PORT
```

---

## Deployment

### Publishing to Roblox

1. **Test Thoroughly**: Ensure everything works in Studio
2. **Save Place**: File → Save to Roblox As...
3. **Configure Settings**: Set game name, description, etc.
4. **Test in Roblox**: Use "Play" button to test published version

### Version Control

**Recommended Git Setup:**
```gitignore
# .gitignore
*.rbxlx.lock
*.rbxl.lock
```

**Backup Important Files:**
- All `.luau` files in `src/`
- `default.project.json`
- `docs/` folder
- `.rbxlx` place file

---

## Getting Help

### Documentation Resources
- [Rojo Documentation](https://rojo.space/docs/)
- [Roblox Developer Hub](https://developer.roblox.com/)
- [Luau Documentation](https://luau-lang.org/)

### Common Commands
```bash
# Start server with verbose output
rojo serve --port 34877 --verbose

# Check project configuration
rojo sourcemap

# Build to file (for analysis)
rojo build --output game.rbxlx
```

### Troubleshooting Steps
1. Check Rojo server console output
2. Verify version compatibility (CLI + plugin both 7.5.1)
3. Restart Rojo server
4. Disconnect/reconnect plugin
5. Restart Roblox Studio
6. Check firewall settings
