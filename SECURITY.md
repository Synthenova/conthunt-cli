# ContHunt MCP security

The Cursor / Agent Plugins install is a **remote Streamable HTTP** server:

```json
{
  "mcpServers": {
    "conthunt": {
      "url": "https://mcp.conthunt.app/"
    }
  }
}
```

- No `command`, `args`, or `env` secrets. Cursor does not spawn a local process.
- Auth is OAuth 2.1 with PKCE via `https://mcp.conthunt.app/.well-known/oauth-protected-resource`. Users approve in the browser.
- `install.sh` / `install.ps1` install the optional ContHunt CLI from GitHub Releases with checksum verification. They are not part of the MCP plugin config and are not executed on Cursor plugin install.
