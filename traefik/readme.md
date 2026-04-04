# Create the external Docker network (required before first run)
docker network create public

---

# Create the hash for basic http authentication
docker run --rm -it httpd:2.4-alpine htpasswd -nB <username>

You will be prompted to enter a password. The hash will be different every time, as the salt changes.