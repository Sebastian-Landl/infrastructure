# tmux Quick Reference

## Create a named session
```bash
tmux new-session -s ollama-pulls
```

## Inside the session, start your pulls
```bash
ollama pull <model>
```

## Detach (leave session running)
```
Ctrl+B, then D
```
Note: The `D` is _without_ Ctrl.

## List existing sessions
```bash
tmux ls
```

## Reattach to a session
```bash
tmux attach -t ollama-pulls
```

## Kill a session when done
```bash
tmux kill-session -t ollama-pulls
```