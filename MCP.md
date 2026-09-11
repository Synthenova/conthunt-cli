# ContHunt MCP

Hosted Streamable HTTP endpoint:

    https://agent.conthunt.app/mcp

OAuth 2.1 with PKCE. The client opens the ContHunt approval page. No API key, no local process.

Official registry name: io.github.synthenova/conthunt

## Codex

    codex mcp add conthunt --url https://agent.conthunt.app/mcp
    codex mcp login conthunt

## Claude Code

    claude mcp add --transport http conthunt https://agent.conthunt.app/mcp

Then run /mcp and complete browser approval.

Plugin marketplace:

    /plugin marketplace add Synthenova/conthunt-cli
    /plugin install conthunt@conthunt

## Cursor

Add to ~/.cursor/mcp.json:

    {
      "mcpServers": {
        "conthunt": {
          "url": "https://agent.conthunt.app/mcp"
        }
      }
    }

## VS Code / GitHub Copilot

    {
      "mcp": {
        "servers": {
          "conthunt": {
            "type": "http",
            "url": "https://agent.conthunt.app/mcp"
          }
        }
      }
    }

## Gemini CLI

    gemini mcp add --transport http -s user conthunt https://agent.conthunt.app/mcp

Then /mcp auth conthunt.

## Windsurf

    {
      "mcpServers": {
        "conthunt": {
          "serverUrl": "https://agent.conthunt.app/mcp"
        }
      }
    }

## Cline

    {
      "mcpServers": {
        "conthunt": {
          "url": "https://agent.conthunt.app/mcp",
          "type": "streamableHttp"
        }
      }
    }

## Claude.ai custom connector

URL: https://agent.conthunt.app/mcp

## Related

- Product: https://conthunt.app
- Privacy: https://conthunt.app/privacy
- Terms: https://conthunt.app/terms
