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

# Choose the right docker image version
Check out the latest releases [here](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/tensorrt-llm/containers/release). If using the DGX Spark, consider using the [spark-single-gpu-dev](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/tensorrt-llm/containers/release?version=spark-single-gpu-dev) tag.

What about nvcr.io/nvidia/tensorrt-llm/release:gpt-oss-dev ?

# Download tiktoken encodings (necessary for openai models)

```bash
bash scripts/download_tiktoken.sh        # writes to ./tiktoken_encodings/
# or custom path:
bash scripts/download_tiktoken.sh /data/tiktoken_encodings
```

Then mount the downloaded encodings into the container at `/app/tiktoken_encodings` (or the custom path you used).
