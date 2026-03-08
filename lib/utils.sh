#!/usr/bin/env bash

# Expand tilde ~ to the user's home directory securely
expand_path() {
    local path="$1"
    echo "${path/#\~/$HOME}"
}

# Extract the current value from the file based on the configured mode
get_current_value() {
    local file=$(expand_path "$1")
    local mode="$2"
    local match="$3"
    local checkpoint="$4"
    local default="$5"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    local val=""
    if [[ "$mode" == "overwrite" ]]; then
        val=$(cat "$file")
    elif [[ "$mode" == "replace" ]]; then
        # awk will find the first line matching the regex
        val=$(awk -v m="$match" '$0 ~ m { print $0; exit }' "$file")
    elif [[ "$mode" == "replace with checkpoint" || -n "$checkpoint" ]]; then
        # awk searches for the checkpoint, then the next matching string
        val=$(awk -v cp="$checkpoint" -v m="$match" '
            $0 ~ cp { found=1; next }
            found==1 && $0 ~ m { print $0; exit }
        ' "$file")
    fi

    # Fallback to default if nothing was found or file was empty
    [[ -z "$val" ]] && echo "$default" || echo "$val"
}

# Apply the requested setting based on mode
apply_setting() {
    local file=$(expand_path "$1")
    local mode="$2"
    local match="$3"
    local checkpoint="$4"
    local value="$5"

    # Ensure the target directory exists
    if [[ $DRY_RUN -eq 0 ]]; then
        mkdir -p "$(dirname "$file")"
    fi

    # Replace .* in the match string with the new value to construct the replacement string
    local replacement="${match//.*/$value}"

    if [[ "$mode" == "overwrite" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\n[TEST MODE] Overwriting $file with: $value\n"
        else
            echo "$value" > "$file"
        fi
    elif [[ "$mode" == "replace" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\n[TEST MODE] Replacing regex '$match' with '$replacement' in $file\n"
        else
            awk -v m="$match" -v r="$replacement" '{ if ($0 ~ m) sub(m, r); print }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
    elif [[ "$mode" == "replace with checkpoint" || -n "$checkpoint" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\n[TEST MODE] Replacing regex '$match' with '$replacement' after checkpoint '$checkpoint' in $file\n"
        else
            awk -v cp="$checkpoint" -v m="$match" -v r="$replacement" '
                $0 ~ cp { found=1; print; next }
                found==1 && $0 ~ m { sub(m, r); found=0; print; next }
                { print }
            ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
    fi
}