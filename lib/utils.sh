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

    # Export for safe AWK parsing
    export AWK_MATCH="$match"
    export AWK_CHECKPOINT="$checkpoint"

    local val=""
    if [[ "$mode" == "overwrite" ]]; then
        val=$(cat "$file")
    elif [[ "$mode" == "replace" && -z "$checkpoint" ]]; then
        val=$(awk '$0 ~ ENVIRON["AWK_MATCH"] { print $0; exit }' "$file")
    elif [[ "$mode" == "replace with checkpoint" || -n "$checkpoint" ]]; then
        val=$(awk '
            $0 ~ ENVIRON["AWK_CHECKPOINT"] { found=1; next }
            found==1 && $0 ~ ENVIRON["AWK_MATCH"] { print $0; exit }
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

    # Safely abort if the file does not exist
    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Ensure the target directory exists just in case (for overwrites)
    if [[ $DRY_RUN -eq 0 ]]; then
        mkdir -p "$(dirname "$file")"
    fi

    # Safely construct the replacement string
    local replacement="${match//\.\*/$value}"

    # Export variables for AWK to read safely from the environment.
    export AWK_MATCH="$match"
    export AWK_REPLACE="$replacement"
    export AWK_CHECKPOINT="$checkpoint"

    if [[ "$mode" == "overwrite" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\n[TEST MODE] Overwriting $file with: $value\n"
        else
            echo "$value" > "$file"
        fi
    elif [[ "$mode" == "replace" && -z "$checkpoint" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\n[TEST MODE] Replacing regex '$match' with '$replacement' in $file\n"
        else
            awk '{ 
                if ($0 ~ ENVIRON["AWK_MATCH"]) sub(ENVIRON["AWK_MATCH"], ENVIRON["AWK_REPLACE"]); 
                print 
            }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
    elif [[ "$mode" == "replace with checkpoint" || -n "$checkpoint" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\n[TEST MODE] Replacing regex '$match' with '$replacement' after checkpoint '$checkpoint' in $file\n"
        else
            awk '
                BEGIN { found_cp=0 }
                $0 ~ ENVIRON["AWK_CHECKPOINT"] { found_cp=1; print; next }
                found_cp==1 && $0 ~ ENVIRON["AWK_MATCH"] { 
                    sub(ENVIRON["AWK_MATCH"], ENVIRON["AWK_REPLACE"]); 
                    found_cp=0; 
                    print; 
                    next 
                }
                { print }
            ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
    fi
}