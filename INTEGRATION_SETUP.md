# MCP and Roblox LSP Integration Setup

This project is configured for **Luau LSP** (editor intelligence) and **Roblox Studio MCP** (AI ↔ Studio integration). Follow these steps to get both working.

---

## Part 1: Roblox LSP (Luau Language Server)

### What it does
- Autocomplete, go-to-definition, hover docs, type checking
- Roblox API types and Rojo sourcemap support
- Full Luau diagnostics in Cursor/VS Code

### Setup

1. **Install the Luau LSP extension**
   - Open Extensions (Ctrl+Shift+X)
   - Search for **"Luau Language Server"** by JohnnyMorganz
   - Install it (or accept the recommendation prompt when opening this project)

2. **Optional: Rojo extension**
   - Search for **"Rojo"** by evaera and install for project sync UI

3. **Sourcemap (automatic)**
   - Luau LSP runs `rojo sourcemap --watch` to resolve `game.ReplicatedStorage.shared`, etc.
   - Ensure `rojo serve` or at least `rojo sourcemap` can run (Rojo 7.3.0+)
   - `sourcemap.json` is generated at project root and added to `.gitignore`

4. **Reload**
   - Reload the window (Ctrl+Shift+P → "Developer: Reload Window") if Luau LSP was just installed

---

## Part 2: Roblox Studio MCP Server

### What it does
- Lets the AI run Lua in Roblox Studio and read console output
- Tools: `run_code`, `insert_model`, `get_console_output`, `start_stop_play`, `run_script_in_play_mode`, `get_studio_mode`
- Useful for testing, debugging, and automation while Studio is open

### Setup (choose one)

#### Option A: Automatic installer (recommended)

1. Download the latest release: https://github.com/Roblox/studio-rust-mcp-server/releases  
   - Windows: get **rbx-studio-mcp.exe** (or the Windows installer from the release assets).
2. Run **rbx-studio-mcp.exe**. The installer sets up Cursor and usually installs the Studio plugin for you.
3. Restart Cursor and Roblox Studio.
4. **Studio plugin:** If the installer ran correctly, the MCP plugin should already be in Studio (Plugins tab). If you don’t see it:
   - Run the exe again (or as Administrator) so it can install the plugin into your Roblox plugins folder, or
   - Check the same [releases page](https://github.com/Roblox/studio-rust-mcp-server/releases) for a separate plugin asset (e.g. `.rbxm`) and install it via **Plugins → Plugin Folder** (place the file in that folder, then restart Studio).  
   The plugin is **not** on the Roblox Creator Marketplace; it only comes from this GitHub repo.

#### Option B: Manual project-level config

1. Download **rbx-studio-mcp.exe** from: https://github.com/Roblox/studio-rust-mcp-server/releases

2. Place it in this project, e.g. `tools/rbx-studio-mcp.exe`:
   ```
   aura-dungeon/
   └── tools/
       └── rbx-studio-mcp.exe
   ```

3. Edit `.cursor/mcp.json`: set `disabled` to `false` and update the path:
   ```json
   {
     "mcpServers": {
       "Roblox_Studio": {
         "command": "C:\\Users\\neila\\OneDrive\\Desktop\\job-exams\\aura-dungeon\\tools\\rbx-studio-mcp.exe",
         "args": ["--stdio"],
         "disabled": false
       }
     }
   }
   ```

4. Install the Roblox Studio MCP plugin in Studio (from the releases page)

5. Restart Cursor, then open Roblox Studio with your place

### Verify MCP

- In Cursor: Ctrl+Shift+P → **"Cursor Settings: Tools & MCP"** (or **"View: Open MCP Settings"**) to open MCP settings and see connected servers
- Confirm **Roblox_Studio** is listed and connected
- In Studio: Plugins tab → MCP plugin icon (toggle on)
- Console should show: `The MCP Studio plugin is ready for prompts.`

---

## Quick reference

| Component   | Role |
|------------|------|
| **Luau LSP** | Autocomplete, types, diagnostics, Rojo-aware requires |
| **Rojo**     | Syncs `src/` ↔ Roblox Studio hierarchy |
| **Roblox MCP** | AI can run code and read output from Studio |

---

## Troubleshooting

**Luau LSP not resolving `require(game.ReplicatedStorage.shared.X)`**
- Ensure `rojo sourcemap --watch default.project.json --output sourcemap.json` runs (Luau LSP does this automatically if `luau-lsp.sourcemap.autogenerate` is true)
- Check `.vscode/settings.json` has `luau-lsp.sourcemap.rojoProjectFile` pointing to your project file

**MCP Roblox_Studio not connecting**
- Use the full absolute path to `rbx-studio-mcp.exe` in `mcp.json`
- Restart Cursor fully (not just reload)
- Ensure Roblox Studio is open with the MCP plugin enabled
