# Pushing Changes to GitHub

This document explains how to push the changes made to the local repository to GitHub using a GitHub App for authentication.

## Prerequisites

- Environment variables set:
  - `GITHUB_APP_ID`: GitHub App ID
  - `GITHUB_PRIVATE_KEY`: GitHub App private key
  - `GITHUB_INSTALLATION_ID`: GitHub App installation ID
- Python 3, `pyjwt`, and `cryptography` packages installed
- Git and curl installed

## Steps to Push Changes

1. **Verify environment variables**:
   ```bash
   echo "GITHUB_APP_ID: $GITHUB_APP_ID" && echo "GITHUB_INSTALLATION_ID: $GITHUB_INSTALLATION_ID"
   echo "$GITHUB_PRIVATE_KEY" | head -n 5
   ```

2. **Save the private key to a file**:
   ```bash
   cd /projects && echo "$GITHUB_PRIVATE_KEY" > github_app_private_key.pem && chmod 600 github_app_private_key.pem
   ```

3. **Create a virtual environment and install required packages**:
   ```bash
   cd /projects && python3 -m venv venv && source venv/bin/activate && pip install pyjwt cryptography
   ```

4. **Generate a JWT token using the private key**:
   ```bash
   cd /projects && source venv/bin/activate && python3 -c "
import jwt
import time
import os

app_id = os.environ['GITHUB_APP_ID']
private_key = '''$GITHUB_PRIVATE_KEY'''

payload = {
    'iat': int(time.time()),
    'exp': int(time.time()) + (10 * 60),
    'iss': app_id
}

encoded_jwt = jwt.encode(payload, private_key, algorithm='RS256')
print(encoded_jwt)
"
   ```

5. **Use the JWT token to get an installation access token**:
   ```bash
   cd /projects && source venv/bin/activate && JWT_TOKEN="[YOUR_JWT_TOKEN]" && curl -X POST -H "Authorization: Bearer $JWT_TOKEN" -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/app/installations/$GITHUB_INSTALLATION_ID/access_tokens
   ```

6. **Use the installation access token to push changes**:
   ```bash
   cd /projects/docker-qwen-code && git remote set-url origin https://x-access-token:[YOUR_ACCESS_TOKEN]@github.com/legido-ai-workspace/docker-qwen-code.git
   git push origin main
   ```

## Alternative: Using GitHub CLI

If you have GitHub CLI installed and configured, you can authenticate and push with:

1. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

2. Push the changes:
   ```bash
   git push origin main
   ```

## Verification

After pushing, verify that your changes are on the remote repository:

```bash
git log --oneline -5
git remote show origin
```