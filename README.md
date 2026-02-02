# replace-vars.sh

A safe, pure-Bash that supports both plain `${VAR}` and `${VAR:-default}` substitution patterns.

This script is especially useful in Docker, CI/CD pipelines, configuration templating, and any environment where you want simple variable substitution with fallback defaults.

## Features

- Replaces `${VAR}` with environment variable value (or empty string if unset)
- Replaces `${VAR:-default}` with environment value if set, otherwise uses the literal default
- Handles escaping of special characters (`/`, `\`, `&`) in values
- Safe against most common sed injection/escaping problems
- No external dependencies — pure Bash + sed

## Supported patterns

| Template              | Env var set? | Result              |
|-----------------------|--------------|---------------------|
| `${PORT}`             | Yes          | value of `$PORT`    |
| `${PORT}`             | No           | (empty string)      |
| `${PORT:-8080}`       | Yes          | value of `$PORT`    |
| `${PORT:-8080}`       | No           | `8080`              |

## Usage

```bash
./replace-vars.sh <input-file> <output-file>

```bash
wget -O - https://raw.githubusercontent.com/osamaMsaeed/pipeline-env/main/replace-vars.sh | bash -s <input-file> <output-file>