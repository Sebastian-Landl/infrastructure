# SeaweedFS S3 Access Guide

## Where to Find Your Credentials

Credentials are defined in `s3.json` — the file mounted into the container at `/etc/seaweedfs/s3.json`.

```json
{
  "identities": [
    {
      "name": "writer",
      "credentials": [
        {
          "accessKey": "writer",          ← this is your AWS_ACCESS_KEY_ID
          "secretKey": "your-secret"      ← this is your AWS_SECRET_ACCESS_KEY
        }
      ],
      "actions": ["Read", "Write", "List", "Tagging"]
    }
  ]
}
```

Your **endpoint URL** is either:
- Local: `http://localhost:8333`
- Via Traefik: `https://<SEAWEEDFS_S3_DOMAIN>` (as set in your `.env`)

---

## AWS CLI

### Install

```bash
pip install awscli
# or
brew install awscli
```

### Configure (one-time)

```bash
aws configure --profile seaweedfs
# AWS Access Key ID:     writer
# AWS Secret Access Key: your-secret
# Default region:        us-east-1   (any value works, SeaweedFS ignores it)
# Default output format: json
```

Or use environment variables instead of a profile:

```bash
export AWS_ACCESS_KEY_ID=writer
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_ENDPOINT_URL=https://s3.yourdomain.com
```

### Common Operations

```bash
# List all buckets
aws s3 ls --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# List contents of a bucket
aws s3 ls s3://test/ --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Upload a single file
aws s3 cp myfile.txt s3://test/ --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Upload a full directory (recursive)
aws s3 cp ./mydir s3://test/mydir/ --recursive \
  --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Download a single file
aws s3 cp s3://test/myfile.txt . --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Download a full directory
aws s3 cp s3://test/mydir/ ./mydir --recursive \
  --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Sync a local directory to a bucket (only uploads changed files)
aws s3 sync ./mydir s3://test/mydir/ \
  --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Delete a file
aws s3 rm s3://test/myfile.txt --profile seaweedfs --endpoint-url https://s3.yourdomain.com

# Delete a directory
aws s3 rm s3://test/mydir/ --recursive \
  --profile seaweedfs --endpoint-url https://s3.yourdomain.com
```

---

## rclone (Best for Directory Sync)

rclone is the recommended tool when you need to sync entire directories — it handles resumable transfers, parallel uploads, dry-run previews, and filtering.

### Install

```bash
# Linux
sudo -v ; curl https://rclone.org/install.sh | sudo bash

# macOS
brew install rclone

# Windows
winget install Rclone.Rclone
```

### Configure

Add the following to `~/.config/rclone/rclone.conf`:

```ini
[seaweedfs]
type = s3
provider = Other
endpoint = https://s3.yourdomain.com
access_key_id = writer
secret_access_key = your-secret
# Optional: force path-style URLs (recommended for SeaweedFS)
force_path_style = true
```

Or run the interactive wizard:

```bash
rclone config
# Choose: n (new remote) → name: seaweedfs → type: s3 → provider: Other
# Fill in endpoint, access key, secret key
```

### Common Operations

```bash
# List buckets
rclone lsd seaweedfs:

# List contents of a bucket
rclone ls seaweedfs:test

# Upload a full directory
rclone copy ./mydir seaweedfs:test/mydir

# Download a full directory
rclone copy seaweedfs:test/mydir ./mydir

# Sync a directory (makes destination mirror source — deletes files not in source)
rclone sync ./mydir seaweedfs:test/mydir

# Dry-run first (see what would happen without doing it)
rclone sync ./mydir seaweedfs:test/mydir --dry-run

# Upload with progress display
rclone copy ./mydir seaweedfs:test/mydir --progress

# Upload in parallel (default is 4, increase for many small files)
rclone copy ./mydir seaweedfs:test/mydir --transfers 16

# Exclude files by pattern
rclone copy ./mydir seaweedfs:test/mydir --exclude "*.tmp" --exclude ".DS_Store"

# Delete files in bucket not present locally
rclone sync ./mydir seaweedfs:test/mydir --delete-during
```

### copy vs sync

| Command | Behaviour |
|---|---|
| `rclone copy` | Copies new/changed files. Never deletes anything at the destination. |
| `rclone sync` | Makes destination identical to source. **Deletes** files at destination that don't exist in source. |

Always run `--dry-run` before your first `sync`.

---

## Python (boto3)

### Install

```bash
pip install boto3
```

### Client setup

```python
import boto3

s3 = boto3.client(
    "s3",
    endpoint_url="https://s3.yourdomain.com",
    aws_access_key_id="writer",
    aws_secret_access_key="your-secret",
    # SeaweedFS does not require a real region, but boto3 needs a value
    region_name="us-east-1",
)
```

### Common Operations

```python
# List buckets
response = s3.list_buckets()
for bucket in response["Buckets"]:
    print(bucket["Name"])

# List objects in a bucket
response = s3.list_objects_v2(Bucket="test")
for obj in response.get("Contents", []):
    print(obj["Key"], obj["Size"])

# Upload a file
s3.upload_file("myfile.txt", "test", "myfile.txt")

# Upload with a specific key (path inside bucket)
s3.upload_file("myfile.txt", "test", "subdir/myfile.txt")

# Upload an entire directory
import os

def upload_directory(local_dir: str, bucket: str, prefix: str = ""):
    for root, dirs, files in os.walk(local_dir):
        for filename in files:
            local_path = os.path.join(root, filename)
            # Preserve relative directory structure
            relative_path = os.path.relpath(local_path, local_dir)
            s3_key = os.path.join(prefix, relative_path).replace("\\", "/")
            print(f"Uploading {local_path} → s3://{bucket}/{s3_key}")
            s3.upload_file(local_path, bucket, s3_key)

upload_directory("./mydir", "test", prefix="mydir")

# Download a file
s3.download_file("test", "myfile.txt", "downloaded.txt")

# Generate a pre-signed URL (time-limited public link)
url = s3.generate_presigned_url(
    "get_object",
    Params={"Bucket": "test", "Key": "myfile.txt"},
    ExpiresIn=3600,  # seconds
)
print(url)

# Delete a file
s3.delete_object(Bucket="test", Key="myfile.txt")
```

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `403 Forbidden` | Wrong credentials or user lacks permission for this bucket | Check `s3.json` — verify `accessKey`/`secretKey` and that the action (`Read`, `Write`) is granted |
| `NoSuchBucket` | Bucket doesn't exist yet | Create it first: `aws s3 mb s3://test --endpoint-url ...` |
| `InvalidAccessKeyId` | `s3.json` not loaded or wrong file path | Check container logs: `docker logs seaweedfs` |
| SSL errors with rclone/boto3 | Self-signed cert | Add `--no-check-certificate` (rclone) or `verify=False` (boto3, dev only) |
| Slow directory uploads | Default parallelism too low | rclone: `--transfers 16`; boto3: use `ThreadPoolExecutor` |
