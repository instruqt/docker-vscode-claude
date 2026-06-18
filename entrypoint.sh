#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Claude Code -> AWS Bedrock
# Written into ~/.claude/settings.json so the configuration survives even if
# the integrated terminal doesn't inherit the container environment for some
# session type. Env vars set on the container take precedence anyway.
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/settings.json" <<EOF
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "${AWS_REGION:-us-east-1}",
    "AWS_ACCESS_KEY_ID": "${AWS_ACCESS_KEY_ID:-}",
    "AWS_SECRET_ACCESS_KEY": "${AWS_SECRET_ACCESS_KEY:-}"
  }
}
EOF

# ---------------------------------------------------------------------------
# Launch code-server
# Auth: password from $PASSWORD (code-server reads it natively).
# ---------------------------------------------------------------------------
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --disable-telemetry \
    --auth none \
    /workspace
