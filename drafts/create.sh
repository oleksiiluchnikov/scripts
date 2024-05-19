#!/bin/zsh
# Description: Create a new draft in Drafts with the neovim editor
# Usage: Run `drafts create` to open a new draft in Neovim
#        or wezterm start --
# Dependencies: Neovim, Drafts

local tmp_file
tmp_file=$(mktemp) # Create a temporary file for the draft message

# Trap to ensure temporary file cleanup
trap 'rm -f "$tmp_file"' EXIT

# If arguments are provided, print them to the temporary file
if [ $# -gt 0 ]; then
    printf "%s\n" "$*" >"$tmp_file"
else

    # Open the temporary file with Neovim and set the filetype to markdown
    nvim -c "set filetype=markdown" -c "startinsert" "$tmp_file" || {
        echo "Error: Failed to open Neovim."
        return 1
    }

    # Check if the file is empty, abort if so
    if [ ! -s "$tmp_file" ]; then
        echo "No draft message provided. Operation aborted."
        return
    fi
fi

# Read the content of the temporary file
local content
content=$(<"$tmp_file")

# Add a new draft with the content
local draft_id
draft_id=$(osascript -e 'tell application "Drafts"
        make new draft with properties {content: "'"$content"'", flagged: false}
    end tell')

# Remove the 'draft id ' prefix to just return the draft ID
draft_id="${draft_id:9}"

echo "Draft created successfully with ID: $draft_id"

# Remove the temporary file (trap will ensure this is done on script exit)
rm -f "$tmp_file"
