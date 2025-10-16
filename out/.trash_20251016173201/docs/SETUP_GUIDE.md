# Setup Guide

## Rojo 7
```bash
cd robot-collectors-new-V1
rojo serve default.project.json --port 34877
```
Studio → Rojo plugin → Connect (`localhost:34877`)

## Server Scripts (expected tree)
`ServerScriptService/World`: `WorldBoot`, `PlotManager.server`, `AutoDoorManager.server`, `Garage/*`  
`ServerScriptService/Server`: `bootstrap.server` (entry)  
`ReplicatedStorage/Shared`: shared modules later

## DataStore (Studio vs Live)
- Studio: expect “You must publish…” warnings. Our PlotManager has a **fallback** and still mounts a single garage.
- Live/Published: Game Settings → **Security** → **Enable Studio Access to API Services** for DS testing.

## Server Caps & Streaming
- Recommend **24–30** max players; **12–16 plots** per shard.
- Enable **StreamingEnabled** so clients stream nearby parts.

