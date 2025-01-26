In order to use `mlflow` with `postgres` and `minio` as storage backend we need the special `Dockerfile` provided here. It createes an image with `mlflow` and all required libraries to interact with `postgres` and `minio`.

## Environment Variables
- `MLFLOW_PORT`: port at which the mlflow UI will be reachable
- `POSTGRED_DB`: name of the postgres database to use for mlflow
- `POSTGRES_PASSWORD`: password for the postgres db
- `MINIO_ROOT_USER`: username for minio
- `MINIO_ROOT_PASSWORD`: password for minio
- `MINIO_BUCKET_NAME`: bucket name used by mlflow
