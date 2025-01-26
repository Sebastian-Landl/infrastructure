## Environment Variables
- `OPENWEBUI_PORT`: Port at which the openwebui will be running
- `OLLAMA_BASE_URL`: `http://host.docker.internal:11434`, if you are running ollama on the docker host on the default ollama port, otherwise simply the base url of the ollama service
#### Additional variables for RAG (not thoroughly tested)
- `RAG_OLLAMA_BASE_URL`: Could be the same as above
- `RAG_EMBEDDING_ENGINE`: e.g. `ollama`
- `RAG_EMBEDDING_MODEL`: e.g. `bge-m3:567m-fp16`
- `ENABLE_RAG_WEB_SEARCH`: `True` or `False`
- `RAG_WEB_SEARCH_RESULT_COUNT`: Number of desired web search results, e.g. `5`

https://docs.openwebui.com/getting-started/advanced-topics/env-configuration/
