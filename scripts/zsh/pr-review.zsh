#!/usr/bin/env zsh

# PR Review Script
# Usage: pr <branch-name> [base-branch]
#   branch-name: The feature/PR branch to review
#   base-branch: The base branch to compare against (auto-detected if not specified)

_pr_completion() {
    local -a branches
    branches=(${(f)"$(git branch --all --format='%(refname:short)' 2>/dev/null | sed 's#^origin/##')"})
    _describe 'branch' branches
}

pr() {
    local branch_name="$1"
    local base_branch="$2"

    # If no branch provided, use fzf to select one
    if [[ -z "$branch_name" ]]; then
        branch_name=$(git branch --all --format='%(refname:short)' 2>/dev/null | \
            sed 's#^origin/##' | \
            sort -u | \
            fzf --prompt="Select PR branch: " --height=40% --reverse --border)

        if [[ -z "$branch_name" ]]; then
            echo "No branch selected"
            return 1
        fi
    fi

    # Auto-detect base branch if not provided
    if [[ -z "$base_branch" ]]; then
        # Try to get the default branch from origin/HEAD
        base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

        # Fall back to common default branch names
        if [[ -z "$base_branch" ]]; then
            if git show-ref --verify --quiet refs/heads/master; then
                base_branch="master"
            elif git show-ref --verify --quiet refs/heads/main; then
                base_branch="main"
            else
                echo "Could not auto-detect base branch. Please specify it explicitly."
                return 1
            fi
        fi

        echo "Auto-detected base branch: $base_branch"
    fi

    echo "Checking out branch: $branch_name"
    git checkout "$branch_name" || {
        echo "Failed to checkout branch: $branch_name"
        return 1
    }

    # Find the merge base between the branches
    local merge_base=$(git merge-base "$base_branch" "$branch_name")

    echo "Opening difftool to compare $branch_name with $base_branch (merge-base: ${merge_base:0:8})..."
    git difftool "$base_branch"..."$branch_name"
}

# Register completion
compdef _pr_completion pr

# If script is executed directly (not sourced), run the function
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]]; then
    pr "$@"
fi
