# Browser-accessible VS Code (Code-OSS, same open-source base as VSCodium,
# telemetry disabled, Open VSX extension registry) with Claude Code wired
# to AWS Bedrock.
FROM codercom/code-server:latest

USER root

# --- System deps + Node.js (required by Claude Code CLI) ---
RUN apt-get update && apt-get upgrade \
    && apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg git ripgrep jq procps \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# --- Claude Code CLI (terminal agent + companion IDE extension) ---
RUN npm install -g @anthropic-ai/claude-code

# --- Claude Code extension (GUI agent, supports AWS Bedrock provider) ---
# Installed from Open VSX, the same registry VSCodium uses.
RUN code-server --install-extension anthropic.claude-code || \
    echo "WARNING: Claude Code install failed"
    
# --- Sensible defaults: no telemetry, dark theme ---
RUN mkdir -p /root/.local/share/code-server/User
COPY settings.json /root/.local/share/code-server/User/settings.json

# --- Entrypoint that wires AWS credentials from env ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /workspace
WORKDIR /workspace
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
