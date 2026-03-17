# Limiting Context Window via Ollama Modelfile

## What is a Modelfile?

A Modelfile is Ollama's Docker-inspired config format for customizing model behavior — system prompts, temperature, stop tokens, and crucially, context window size (`num_ctx`).

---

## 1. Find Your Base Model Name

```bash
ollama list
```

Pick the model you want to wrap, e.g. `qwen2.5-coder:32b`.

---

## 2. Create the Modelfile

```dockerfile
# Modelfile
FROM qwen2.5-coder:32b

# Limit context to 8192 tokens (default is often 128k+)
PARAMETER num_ctx 8192

# Optional: lock in a system prompt
SYSTEM "You are a focused coding assistant. Be concise."
```

> **Key parameters:**
> | Parameter | Description |
> |-----------|-------------|
> | `num_ctx` | Max context window in tokens |
> | `num_predict` | Max tokens to generate per response |
> | `temperature` | Sampling temperature (0.0–1.0) |
> | `top_p` | Nucleus sampling cutoff |

---

## 3. Build the Custom Model

```bash
ollama create qwen-coder-8k -f ./Modelfile
```

Verify it exists:

```bash
ollama list
# qwen-coder-8k   ...
```

---

## 4. Run It

```bash
ollama run qwen-coder-8k
```

Or via API:

```bash
curl http://localhost:11434/api/generate \
  -d '{"model": "qwen-coder-8k", "prompt": "Write a Python hello world"}'
```

---

## 5. Verify the Context is Applied

```bash
ollama show qwen-coder-8k --modelfile
# Should show: PARAMETER num_ctx 8192
```

You can also check at runtime — Ollama logs will show `num_ctx` in the model load output.

---

## Why Limit Context?

- **VRAM**: Larger `num_ctx` directly increases KV cache memory usage. On your 48GB setup, a 32B model at 128k ctx will eat far more VRAM than at 8k.
- **Latency**: Prefill time scales with context length.
- **Focused inference**: For coding agents, a tight context forces better prompt design.

---

## Notes

- The `FROM` directive can reference a local model name or a full Ollama Hub path.
- Modelfiles are not Dockerfiles — only a subset of directives is supported (`FROM`, `PARAMETER`, `SYSTEM`, `TEMPLATE`, `ADAPTER`, `LICENSE`, `MESSAGE`).
- Changing `num_ctx` does **not** retrain the model — it only caps the KV cache allocation at runtime.
- If you push to a local Ollama registry or share the Modelfile, the base model must already exist on the target host.