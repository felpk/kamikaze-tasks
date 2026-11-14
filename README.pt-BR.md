# kamikaze-tasks

[English](README.md) · [Français](README.fr.md)

Uma tarefa, um contrato, uma execução, e o pane morre.

**Problema.** Você dá uma tarefa única pra um agente. Ele faz mais do que pediu, ou menos, e diz "pronto" sem provar. O pane do tmux fica aberto e as ideias paralelas se perdem.

**Solução.** O `kt` coloca o CLI `claude` num ciclo fixo:

1. **Contrato.** O Claude lê o repo (modo plan, só leitura) e escreve o objetivo, de 1 a 5 checagens verificáveis por comando, o que ele *não* vai fazer, as suposições e o risco. Pergunta no máximo 3 coisas, só quando um chute errado estragaria a execução.
2. **Confirmação.** Enter, uma correção, ou sair. `--yes` pula isso quando o risco é baixo. Risco alto sempre pergunta.
3. **Execução.** Sem perguntas e sem espera. Comandos destrutivos (`rm -rf`, `push --force`, `reset --hard`, `docker volume rm`, `terraform destroy`…) são bloqueados. Se a tarefa precisar de um, a execução para em `BLOCKED` e te passa o comando exato.
4. **Verificação.** Cada checagem é rodada e citada. `DONE` com checagem falha vira `FAILED`.
5. **Morte.** O que ele achou fora do escopo vai pra um inbox, e o pane do tmux fecha.

## Instalar

Precisa de bash, `jq`, tmux (opcional) e do CLI do [Claude Code](https://claude.com/claude-code).

```sh
git clone https://github.com/felpk/kamikaze-tasks && cd kamikaze-tasks && ./install.sh
```

Atalho no tmux (prefixo + K abre um pane kamikaze):

```tmux
bind K split-window -c '#{pane_current_path}' kt
```

Dentro do Claude Code, o mesmo ciclo é uma skill:

```
/plugin marketplace add felpk/kamikaze-tasks
/plugin install kamikaze-tasks@kamikaze-tasks
```

## Uso

```
kt "tarefa"               contrato -> confirma -> roda -> verifica -> pane fecha
kt                        pergunta a tarefa antes (pra atalho de teclado)
kt new "tarefa"           o mesmo, num pane novo do tmux
kt resume <id> [resposta] continua uma execução BLOCKED
kt inbox [take N|clear]   achados paralelos guardados
kt log [id]               execuções anteriores
kt park "texto"           adiciona uma linha no inbox
```

Opções, variáveis e testes: veja o [README em inglês](README.md).

MIT
