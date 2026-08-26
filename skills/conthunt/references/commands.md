# ContHunt command reference

## Authentication

```text
conthunt login
conthunt logout
conthunt whoami --json
```

Authentication resolution order is `--token`, `CONTHUNT_TOKEN`, then the credential saved by `conthunt login`.

## Searches and media

```text
conthunt search start <query> [--tiktok] [--tiktok-top] [--instagram] [--youtube] [--amount N] --json
conthunt search list --json
conthunt search status <search-id> --json
conthunt search get <search-id> --json
conthunt search wait <search-id> --json
conthunt download url <media-asset-id> --json
conthunt download file <media-asset-id> -o <path> --json
conthunt analyze start <media-asset-id> --json
conthunt analyze status <media-asset-id> --json
conthunt analyze get <media-asset-id> --json
conthunt analyze wait <media-asset-id> --json
```

Search defaults to TikTok, Instagram, and YouTube when no platform flag is supplied.

## Boards and insights

```text
conthunt board list --json
conthunt board create <name> --json
conthunt board get <board-id> --json
conthunt board items <board-id> --json
conthunt board delete <board-id> --json
conthunt board add <board-id> <content-item-id> [<content-item-id> ...] --json
conthunt board remove <board-id> <content-item-id> --json
conthunt insights start <board-id> --json
conthunt insights status <board-id> --json
conthunt insights get <board-id> --json
conthunt insights wait <board-id> --json
```

## Chat

```text
conthunt chat create [--title <title>] [--board <id>] [--search <id>] --json
conthunt chat send <chat-id> <message> --json
conthunt chat status <chat-id> --json
conthunt chat get <chat-id> --json
conthunt chat wait <chat-id> --json
conthunt chat resume <chat-id> --json
conthunt chat tags <chat-id> --json
conthunt chat list --json
conthunt chat delete <chat-id> --json
```

Each `send` adds another turn to the same chat ID. `get` returns useful messages and associated search IDs without raw internal tool payloads.

## Deep research

```text
conthunt research start <brief> [--title <title>] [--board <id>] [--search <id>] --json
conthunt research send <chat-id> <message> --json
conthunt research status <chat-id> --json
conthunt research get <chat-id> --json
conthunt research wait <chat-id> --json
conthunt research resume <chat-id> --json
conthunt research list --json
```

Research uses the same multi-turn chat ID model. `status` stays small; `get` returns the completed report, slim canvas, messages, and search IDs.

## Trending

```text
conthunt trending youtube --json
conthunt trending tiktok --json
conthunt trending niches --json
```

Trending is an immediate GET, not a background job.

## Exit codes

| Code | Meaning |
|---:|---|
| 0 | Success; an active `status` is still successful |
| 1 | Job failure or unexpected API/transport error |
| 2 | Invalid command or flag |
| 3 | Authentication missing or rejected |
| 4 | Result or asset is not ready |
| 5 | Resource not found |
| 6 | Access denied |
