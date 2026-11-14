# kamikaze-tasks

[English](README.md) · [Português](README.pt-BR.md)

Une tâche, un contrat, une exécution, puis le pane meurt.

**Problème.** Vous donnez une tâche unique à un agent. Il en fait plus que demandé, ou moins, puis dit « fini » sans le prouver. Le pane tmux reste ouvert et les idées annexes se perdent.

**Solution.** `kt` enferme le CLI `claude` dans une boucle fixe :

1. **Contrat.** Claude lit le dépôt (mode plan, lecture seule) et écrit le but, 1 à 5 vérifications qu'une commande peut prouver, ce qu'il ne fera *pas*, ses hypothèses et le risque. Au plus 3 questions, seulement quand une erreur gâcherait l'exécution.
2. **Confirmation.** Entrée, une correction, ou quitter. `--yes` saute cette étape si le risque est faible. Un risque élevé demande toujours.
3. **Exécution.** Aucune question, aucune attente. Les commandes destructrices (`rm -rf`, `push --force`, `reset --hard`, `docker volume rm`, `terraform destroy`…) sont bloquées. Si la tâche en exige une, l'exécution s'arrête en `BLOCKED` et vous donne la commande exacte.
4. **Vérification.** Chaque vérification est lancée et citée. Un `DONE` avec une vérification ratée devient `FAILED`.
5. **Mort.** Les trouvailles hors périmètre vont dans une boîte de réception, et le pane tmux se ferme.

## Installation

Il faut bash, `jq`, tmux (optionnel) et le CLI [Claude Code](https://claude.com/claude-code).

```sh
git clone https://github.com/felpk/kamikaze-tasks && cd kamikaze-tasks && ./install.sh
```

Raccourci tmux (préfixe + K ouvre un pane kamikaze) :

```tmux
bind K split-window -c '#{pane_current_path}' kt
```

Dans Claude Code, la même boucle existe en skill :

```
/plugin marketplace add felpk/kamikaze-tasks
/plugin install kamikaze-tasks@kamikaze-tasks
```

## Utilisation

```
kt "tâche"                contrat -> confirmer -> exécuter -> vérifier -> pane fermé
kt                        demande la tâche d'abord (pour un raccourci)
kt new "tâche"            pareil, dans un nouveau pane tmux
kt resume <id> [réponse]  reprend une exécution BLOCKED
kt inbox [take N|clear]   trouvailles annexes mises de côté
kt log [id]               exécutions passées
kt park "texte"           ajoute une ligne à la boîte
```

Options, variables et tests : voir le [README anglais](README.md).

MIT
