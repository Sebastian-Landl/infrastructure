This Tabby config is designed for servers with an nvidia GPU. The model referenced in the config should be updated.

## Enviorment Variables
- `TABBY_DATA`: Path to store some Tybby data
- `TABBY_WEBSERVER_JWT_TOKEN_SECRET`: needs to be a valid `UUID`. You can use `python` to generate a `UUID` locally: `python -c "from uuid import uuid4; print(uuid4())"`
