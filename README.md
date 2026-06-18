# Browser VS Code + Claude Code on AWS Bedrock

A Dockerized, browser-accessible VS Code environment with Claude Code pre-installed and wired to **AWS Bedrock** — no Anthropic account or API key required.

- **Claude Code CLI** — runs in the integrated terminal; the companion IDE extension is also installed, giving you the sidebar/diff integration.
- **AWS Bedrock** — all Claude requests route through Bedrock using standard AWS credentials injected via environment variables.

The editor is [code-server](https://github.com/coder/code-server), the open-source browser build of VS Code (telemetry disabled, Open VSX extension registry).

A pre-built docker container is available at `gcr.io/instruqt/vscode-claude`.

## Layout

```
.
├── Dockerfile
├── entrypoint.sh
└── settings.json
```

## Quick start

1. Build the image:

   ```bash
   docker build -t vscode-claude .
   ```

2. Run it with your AWS credentials:

   ```bash
   docker run -d \
     -p 8080:8080 \
     -e AWS_REGION=us-east-1 \
     -e AWS_ACCESS_KEY_ID=<your-key-id> \
     -e AWS_SECRET_ACCESS_KEY=<your-secret> \
     vscode-claude
   ```

3. Open `http://localhost:8080` — no password required.

4. Open a terminal in the editor (`` Ctrl+` ``) and run:

   ```bash
   claude
   ```

   Claude Code talks to Bedrock directly using the credentials from step 2.

## How the Bedrock wiring works

The entrypoint writes the following to `~/.claude/settings.json` at startup so the configuration is available to all session types, not just the integrated terminal:

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_BEDROCK=1` | Routes Claude Code through AWS Bedrock instead of the Anthropic API |
| `AWS_REGION` | Bedrock region (defaults to `us-east-1`) |
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |

The IAM principal needs `bedrock:InvokeModel` and `bedrock:InvokeModelWithResponseStream` on the Claude model ARNs you intend to use — the AWS managed policy `AmazonBedrockLimitedAccess` covers both. Make sure the models are enabled in the [Bedrock Model Access console](https://console.aws.amazon.com/bedrock/home#/modelaccess) for your region.
