#!/usr/bin/env bash

# Check what's running on a port
whatport() {
    if [ -n "$1" ]; then
        lsof -nP -i4TCP:"$1"
    else
        echo "Provide a port"
    fi
}

# Run a command N times
run() {
    local number=$1
    shift
    local i
    for ((i = 0; i < number; i++)); do
        "$@"
    done
}

# Interactive git diff file selector
fdif() {
    preview="git diff $* --color=always -- {-1}"
    git diff "$@" --name-only | fzf -m --ansi --preview "$preview"
}

# VSCode tmux session
codemux() {
    tmux a -t VSCode || tmux new -s VSCode
}

# Show head and tail of a file
headtail() {
    head "$@"
    tail "$@"
}

lambda_node_logs() {
    docker logs "$(docker ps --filter ancestor=public.ecr.aws/lambda/nodejs:20 -q)" --follow
}

dlogs() {
    container_id=$(docker container ls | grep -i "$1" | awk '{print $1}')

    container_count=$(echo "$container_id" | wc -l)

    if [ "$container_count" -eq 1 ]; then
        docker logs "$container_id" --follow
    elif [ "$container_count" -gt 1 ]; then
        echo "Multiple containers found. Please specify further."
        echo "$container_id"
    else
        echo "No containers found matching '$1'."
    fi
}

pip_compile() {
    # Check if we're in a virtual environment and set pip-compile command accordingly
    local pip_compile_cmd="pip-compile"
    if [ -d ".venv" ]; then
        pip_compile_cmd=".venv/bin/pip-compile"
    fi

    echo "executing '$pip_compile_cmd -U -o requirements.txt requirements.in'"
    $pip_compile_cmd -U -o requirements.txt requirements.in
    echo "Done!"

    # Check if requirements-dev.in exists before processing
    if [ -f "requirements-dev.in" ]; then
        echo "executing '$pip_compile_cmd -U -o requirements-dev.txt requirements.in requirements-dev.in'"
        $pip_compile_cmd -U -o requirements-dev.txt requirements.in requirements-dev.in
        echo "Done!"
    fi

    # Use pip-sync from the virtual environment if it exists
    local pip_sync_cmd="pip-sync"
    if [ -d ".venv" ]; then
        pip_sync_cmd=".venv/bin/pip-sync"
    fi

    echo "executing '$pip_sync_cmd requirements.txt'"
    $pip_sync_cmd requirements.txt
    echo "Done!"
}

# Renumber NNN_*.sql migrations to make room for a new one at position $1
insert_file_in_sequence() {
    sudo bash -c '
    for f in $(ls | sort -r); do
        if [[ $f =~ ^[0-9]+ ]]; then
            current="${BASH_REMATCH[0]}"
            if [ "$current" -ge "$1" ]; then
                mv "$f" "${f/$current/$((current + 1))}"
            fi
        fi
    done
    touch "${1}_new.sql"
    ' -- "$1"
}

# Print a JSON document's shape, with leaf values replaced by their type
get_json_schema() {
    jq '
  def schema:
    if type == "object" then
      reduce (to_entries[]) as $item ({};
        . + { ($item.key): ($item.value | schema) }
      )
    elif type == "array" and length > 0 then
      [.[0] | schema]
    else
      type
    end;
  schema
  ' "$@"
}
