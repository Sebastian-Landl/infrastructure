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