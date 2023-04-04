#!/bin/zsh

function source_venv()
{
    # Set the directory path where the virtual environments are stored
    local venv_dir="$HOME/venvs"

    ls $venv_dir

    # Prompt user for the virtual environment name
    echo "Enter the name of the virtual environment to activate:"
    read venv_name

    # Check if the virtual environment exists
    if [ -d "$venv_dir/$venv_name" ]; then
        # Activate the virtual environment
        source "$venv_dir/$venv_name/bin/activate"
        echo "Activated virtual environment: $venv_name"
    else
        echo "Virtual environment $venv_name not found in $venv_dir"
    fi
}
