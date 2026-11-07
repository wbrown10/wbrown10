#!/usr/bin/env bash
# Liga os serviços em segundo plano: OmniRoute (20128), claude-mem (37700) e Headroom (8787).
# Logs em ~/.toolkit-logs/. Para parar: bash start.sh stop
set -uo pipefail
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
LOGS="$HOME/.toolkit-logs"; mkdir -p "$LOGS"

if [ "${1:-}" = "stop" ]; then
  omniroute stop 2>/dev/null; claude-mem stop 2>/dev/null; pkill -f "headroom proxy" 2>/dev/null
  echo "Serviços parados."; exit 0
fi

up() { curl -s -o /dev/null --max-time 2 "$1"; }

# Escuta só nesta máquina, por segurança.
if up http://127.0.0.1:20128/api/health; then echo "OmniRoute já está rodando."
else OMNIROUTE_SERVER_HOST=127.0.0.1 nohup omniroute serve >"$LOGS/omniroute.log" 2>&1 & fi

if up http://127.0.0.1:37700/; then echo "claude-mem já está rodando."
else claude-mem start >"$LOGS/claude-mem.log" 2>&1; fi

# Sem envio de resumos anônimos para a Headroom Labs.
if up http://127.0.0.1:8787/health; then echo "Headroom já está rodando."
else HEADROOM_BEACON=off nohup headroom proxy >"$LOGS/headroom.log" 2>&1 & fi

echo "Aguardando os serviços subirem..."
for _ in $(seq 1 30); do
  up http://127.0.0.1:20128/api/health && up http://127.0.0.1:37700/ && up http://127.0.0.1:8787/health && break
  sleep 2
done
printf '%-12s %s\n' "OmniRoute"  "$(up http://127.0.0.1:20128/api/health && echo 'OK  http://localhost:20128' || echo 'FALHOU (veja ~/.toolkit-logs/omniroute.log)')"
printf '%-12s %s\n' "claude-mem" "$(up http://127.0.0.1:37700/ && echo 'OK  http://localhost:37700' || echo 'FALHOU (veja ~/.toolkit-logs/claude-mem.log)')"
printf '%-12s %s\n' "Headroom"   "$(up http://127.0.0.1:8787/health && echo 'OK  http://localhost:8787' || echo 'FALHOU (veja ~/.toolkit-logs/headroom.log)')"
