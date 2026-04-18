# Image

- DGX Spark: [avarok/dgx-vllm-nvfp4-kernel:v23](https://hub.docker.com/layers/avarok/dgx-vllm-nvfp4-kernel/v23/images/sha256-365447a3b5a172e96c50e69f761a15e45fff2a7487f46172a84a4cf806f25f5d)
- Other: vllm/vllm-openai:nightly

# Download nvfp4 models from huggingface
The tensorrt container does that by itself, but for time saving you may want to pre-download them on the host and mount them in. Example:

```bash
uvx hf download nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B-NVFP4
```

Check downloaded models:

```bash
uvx hf cache ls
```

In this case we'd mount the normal huggingface cache directory (`~/.cache/huggingface`) into the container at the same location, so the container can find the downloaded models.

## Reasoning parsers
The reasoning parsers are custom plugins for vLLM that enable advanced reasoning capabilities. You can find them in the `reasoning_parsers` directory. To use a specific reasoning parser, set the `VLLM_REASONING_PARSER_PLUGIN` environment variable to the path of the desired parser plugin within the container (e.g., `/app/reasoning_parsers/nano_v3_reasoning_parser.py`) and set the `VLLM_REASONING_PARSER` variable to the corresponding parser name (e.g., `nano_v3`).
