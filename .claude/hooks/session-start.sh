#!/bin/bash
# Liga OmniRoute, claude-mem e Headroom ao começar uma sessão do Claude Code.
# A instalação é feita pelo install.sh; aqui só ligamos o que já está instalado.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

missing=""
for cmd in omniroute claude-mem headroom; do
  command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
if [ -n "$missing" ]; then
  echo "Kit de ferramentas: faltando$missing. Rode 'bash install.sh' para instalar." >&2
  exit 0
fi

# Nunca bloqueia a sessão: se algo falhar, o start.sh mostra onde estão os logs.
bash ./start.sh || echo "Kit de ferramentas: start.sh falhou (veja ~/.toolkit-logs)." >&2
exit 0
