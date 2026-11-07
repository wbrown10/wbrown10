#!/usr/bin/env bash
# Instala o kit de ferramentas para o Claude Code:
#   OmniRoute, claude-mem, Headroom, claude-plugins-official e Task Observer.
# Pode rodar quantas vezes quiser: o que já estiver instalado é atualizado ou pulado.
# Uso:  bash install.sh
set -euo pipefail

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

# ---------- Pré-requisitos ----------
log "Verificando pré-requisitos"
have node || { echo "Node.js não encontrado. Instale o Node 22 ou 24: https://nodejs.org" >&2; exit 1; }
have npm  || { echo "npm não encontrado." >&2; exit 1; }
have git  || { echo "git não encontrado." >&2; exit 1; }
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "Node $NODE_MAJOR é antigo demais: o OmniRoute precisa do Node 22 ou mais novo." >&2; exit 1
fi
if ! have uv; then
  log "Instalando uv (para o Headroom)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# ---------- 1. OmniRoute ----------
log "1/5 OmniRoute (roteador de IA)"
npm install -g omniroute

# ---------- 2. claude-mem ----------
log "2/5 claude-mem (memória entre sessões)"
npm install -g claude-mem
claude-mem install --ide claude-code --provider claude --runtime worker --no-auto-start </dev/null \
  || warn "claude-mem: instalação não terminou; rode 'npx claude-mem install' manualmente."

# ---------- 3. Headroom ----------
log "3/5 Headroom (compressão de contexto)"
uv tool install --upgrade --python 3.13 "headroom-ai[proxy,mcp]"

# ---------- 4. claude-plugins-official ----------
log "4/5 Catálogo claude-plugins-official"
if have claude; then
  if claude plugin marketplace list 2>/dev/null | grep -q 'claude-plugins-official'; then
    echo "Catálogo já adicionado."
  else
    claude plugin marketplace add anthropics/claude-plugins-official \
      || warn "Não consegui adicionar o catálogo; rode: claude plugin marketplace add anthropics/claude-plugins-official"
  fi
else
  warn "Claude Code não encontrado; pulei o catálogo de plugins. Instale com: npm install -g @anthropic-ai/claude-code"
fi

# ---------- 5. Task Observer ----------
log "5/5 Task Observer (skill)"
SKILL_DIR="$HOME/.claude/skills/task-observer"
TMP=$(mktemp -d)
git clone -q --depth 1 https://github.com/rebelytics/one-skill-to-rule-them-all.git "$TMP/src"
mkdir -p "$SKILL_DIR"
cp -r "$TMP/src/SKILL.md" "$TMP/src/references" "$TMP/src/scripts" "$TMP/src/LICENSE" "$SKILL_DIR/"
rm -rf "$TMP"
echo "Skill em $SKILL_DIR"

log "Pronto! Para ligar os serviços, rode: bash start.sh"
