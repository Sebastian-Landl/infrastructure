## Environment Variables
- `OLLAMA_VOLUME`: Path where the models are stored (*Note: they can take a lot of space*)

#### GPU Only
- `OLLAMA_GPU_DRIVER`: e.g. `nvidia`

## AVX Support in VMs
Next, at the time of writing this Ollama requires AVX instructions on the CPU to work with GPUs. Most modern CPUs support this, but to get these instructions in a Proxmox VM, you need to change the CPU type to `host` in VM -> Hardware -> Processor -> Type.  
Source: https://support.regulaforensics.com/hc/en-us/articles/20319657014929-CPU-doesn-t-support-image-x86-64-v2-error-using-Proxmox

## Model management
For managing the LLMs available to the container, I pull the required images at the first deployment (subsequent deployments can reuse them, as they are persisted at `OLLAMA_VOLUME`) using the following commands on the docker host VM/machine:
- `docker ps` to get the ID of the ollama container
- `docker exec -it <container_id> /bin/bash` to get a bash inside the container
- `ollama pull <model>` to pull the actual model

## litellm_model_backend network
This network is declared in the litellm docker-compose.yml and is used to allow the ollama container to communicate with the litellm proxy container, without exposing the ollama container to the public network. The litellm proxy can then route requests to the ollama container when a request is made to the corresponding model.