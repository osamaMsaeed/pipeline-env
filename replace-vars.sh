#!/usr/bin/env bash
# replace-vars.sh
#
# Usage: ./replace-vars.sh <input> <output>
# Template file with ${VAR} and ${VAR:-default} syntax is read from <input>,
# environment variables are substituted, and the result is written to <output>.

INPUT="${1:-}"
OUTPUT="${2:-}"

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
    echo "Usage: $0 <input> <output>" >&2
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Input file not found: $INPUT" >&2
    exit 1
fi

# ─── Extract all variable names ─────────────────────────────────────
# We keep only the name part (before :-, :=, etc.)
VAR_NAME_REGEX='[A-Za-z_][A-Za-z0-9_]*'
VARS=$(grep -oE '\$\{'"$VAR_NAME_REGEX"'(:-[^}]*)?\}' "$INPUT" \
    | sed -E 's/^\$\{([^:}]+).*$/\1/' \
    | sort -u)

# ─── Build value map ────────────────────────────────────────────────
declare -A VALUES

for var in $VARS; do
    if [[ -v "$var" ]]; then
        VALUES["$var"]="${!var}"
    else
        VALUES["$var"]=""
    fi
done

# ─── Process file ───────────────────────────────────────────────────
content=$(<"$INPUT")

for var in "${!VALUES[@]}"; do
    value="${VALUES[$var]}"

    esc_value="$value"
    esc_value="${esc_value//\\/\\\\}"
    esc_value="${esc_value//&/\\&}"
    esc_value="${esc_value//\//\\/}"

    # First: expand ${VAR:-default} correctly
    if [[ -n "${value}" ]]; then
        # has value → replace whole ${VAR:-…} with value
        content=$(sed -E "s#\\$\\{$var:-[^}]*\\}#${esc_value}#g" <<< "$content")
    else
        # no value → replace with the default (capture group)
        content=$(sed -E "s#\\$\\{$var:-([^}]*)\\}#\\1#g" <<< "$content")
    fi

    # Second: replace remaining plain ${VAR}
    content=$(sed -E "s#\\$\\{$var\\}#${esc_value}#g" <<< "$content")
done

printf '%s\n' "$content" > "$OUTPUT"

echo "✔ Rendered $OUTPUT successfully"