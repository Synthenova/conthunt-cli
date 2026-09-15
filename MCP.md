# ContHunt MCP

Hosted Streamable HTTP endpoint:

    https://mcp.conthunt.app/

OAuth 2.1 with PKCE. The client opens the ContHunt approval page. No API key, no local process.

Official registry name: io.github.synthenova/conthunt

## Codex

    codex mcp add conthunt --url https://mcp.conthunt.app/
    codex mcp login conthunt

## Claude Code

    claude mcp add --transport http conthunt https://mcp.conthunt.app/

Then run /mcp and complete browser approval.

Plugin marketplace:

    /plugin marketplace add Synthenova/conthunt-cli
    /plugin install conthunt@conthunt

## Cursor

Add to ~/.cursor/mcp.json:

    {
      "mcpServers": {
        "conthunt": {
          "url": "https://mcp.conthunt.app/"
        }
      }
    }

## VS Code / GitHub Copilot

    {
      "mcp": {
        "servers": {
          "conthunt": {
            "type": "http",
            "url": "https://mcp.conthunt.app/"
          }
        }
      }
    }

## Gemini CLI

    gemini mcp add --transport http -s user conthunt https://mcp.conthunt.app/

Then /mcp auth conthunt.

## Windsurf

    {
      "mcpServers": {
        "conthunt": {
          "serverUrl": "https://mcp.conthunt.app/"
        }
      }
    }

## Cline

    {
      "mcpServers": {
        "conthunt": {
          "url": "https://mcp.conthunt.app/",
          "type": "streamableHttp"
        }
      }
    }

## Claude.ai custom connector

URL: https://mcp.conthunt.app/

## Related

- Product: https://conthunt.app
- Privacy: https://conthunt.app/privacy
- Terms: https://conthunt.app/terms
