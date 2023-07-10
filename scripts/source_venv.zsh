#!/usr/bin/env zsh

# Set the directory path where the virtual environments are stored
local venv_dir="$HOME/venvs"

# Define a function to provide completion options based on the directories in the venv folder
_venv_completion() {
    local file
    for file in ~/venvs/*; do
        # Skip entries that are not a directory.
        [[ -d $file ]] || continue

        # Add the file without the ~/venvs/ prefix to the list of 
        # autocomplete suggestions.
        COMPREPLY+=( $(basename "$file") )
    done
}

# Set the completion function for the "source_venv" command
complete -F _venv_completion source_venv

source_venv()
{
    local venv_name="$1"
    if [ -d "${venv_dir}/${venv_name}" ]; then
        source "${venv_dir}/${venv_name}/bin/activate"
        echo "Activated virtual environment: ${venv_name}"
    else
        echo "Virtual environment ${venv_name} not found in ${venv_dir}"
    fi
}
