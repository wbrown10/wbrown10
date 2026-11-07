# Kit de ferramentas para o Claude Code

Scripts que instalam e ligam:

| Ferramenta | O que faz | Porta |
|---|---|---|
| [OmniRoute](https://github.com/diegosouzapw/OmniRoute) | Roteador de IA: um endpoint compatível com OpenAI para mais de 60 provedores | 20128 |
| [claude-mem](https://github.com/thedotmack/claude-mem) | Memória entre sessões do Claude Code | 37700 |
| [Headroom](https://github.com/headroomlabs-ai/headroom) | Comprime o contexto antes de cada chamada ao modelo | 8787 |
| [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Catálogo oficial de plugins da Anthropic | — |
| [Task Observer](https://github.com/rebelytics/one-skill-to-rule-them-all) | Skill que propõe melhorias nas suas skills | — |

## Requisitos

- Node.js 22 ou 24, npm e git
- Claude Code (`npm install -g @anthropic-ai/claude-code`)
- `uv` (o script instala se faltar)

## Uso

```bash
git clone https://github.com/wbrown10/wbrown10.git
cd wbrown10
bash install.sh   # instala tudo
bash start.sh     # liga os 3 serviços
bash start.sh stop
```

Depois, abra uma **sessão nova** do Claude Code para os plugins e a skill carregarem.

**Ligação automática:** o gancho `.claude/hooks/session-start.sh` roda o `start.sh` sempre que uma sessão do Claude Code começa nesta pasta. Se as ferramentas não estiverem instaladas, ele só avisa e não trava a sessão.

## Próximos passos

- **OmniRoute:** abra http://localhost:20128, conecte um provedor (OpenAI, Anthropic, Gemini…) e crie uma chave em *Endpoints*.
- **Headroom com o Claude Code:** `ANTHROPIC_BASE_URL=http://localhost:8787 claude`
- **Plugins oficiais:** `claude plugin install <nome>@claude-plugins-official`
- **Task Observer:** adicione ao seu `CLAUDE.md`:
  > At the start of every task-oriented session, invoke the task-observer skill before your first tool call.

## Privacidade

- O `start.sh` liga o Headroom com `HEADROOM_BEACON=off`, sem enviar resumos anônimos.
- O OmniRoute só aceita conexões da própria máquina (`127.0.0.1`).
- O claude-mem tem telemetria anônima ligada por padrão. Para desligar: `claude-mem telemetry disable`.
