## Environment Variables
- `OLLAMA_VOLUME`: Path where the models are stored (*Note: they can take a lot of space*)

#### GPU Only
- `OLLAMA_CUDA_VISIBLE_DEVICES`: See [Nvidia GPU ID](#nvidia-gpu-id)
- `OLLAMA_GPU_DRIVER`: e.g. `nvidia`

## Nvidia GPU ID
To decide which GPUs to use first run `nvidia-smi -L` on the host machine to get the long IDs of the GPUs. Add these to the `CUDA_VISIBLE_DEVICES` like so (comma separated, if you have multiple GPUs):
- `OLLAMA_CUDA_VISIBLE_DEVICES=GPU-2b899d08-f3dc-ef67-d8cc-dc4a869da8c6`

Source: https://www.reddit.com/r/ollama/comments/1d8vdgz/comment/l7biua2/?share_id=riRQvmbzjE7iLcjQ0NGQ-&utm_content=2&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=1

## AVX Support in VMs
Next, at the time of writing this Ollama requires AVX instructions on the CPU to work with GPUs. Most modern CPUs support this, but to get these instructions in a Proxmox VM, you need to change the CPU type to `host` in VM -> Hardware -> Processor -> Type.  
Source: https://support.regulaforensics.com/hc/en-us/articles/20319657014929-CPU-doesn-t-support-image-x86-64-v2-error-using-Proxmox

## Model management
For managing the LLMs available to the container, I pull the required images at the first deployment (subsequent deployments can reuse them, as they are persisted at `OLLAMA_VOLUME`) using the following commands on the docker host VM/machine:
- `docker ps` to get the ID of the ollama container
- `docker exec -it <container_id> /bin/bash` to get a bash inside the container
- `ollama pull <model>` to pull the actual model
