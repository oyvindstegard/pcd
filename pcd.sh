# Project cd
PROJECTS_PATH=${PROJECTS_PATH:-~/projects}

# Main command function
pcd() {
    local args=() op=cd opt OPTIND
    # Option parsing ergonomics: allow options anywhere in command line
    while [ $# -gt 0 ]; do
        while getopts 'p' opt; do
            [ $opt = p ] && op=pushd || return 1
        done
        shift $((OPTIND-1)) && OPTIND=1
        [ $# -gt 0 ] && args+=("$1") && shift
    done
    
    local path="$PROJECTS_PATH/${args[0]}/${args[1]}"
    if [ "${args[0]}" = .. ]; then
        local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -d "$gitroot" ]; then
            path="$gitroot/${args[1]}"
        fi
    fi
    
    if [ -d "$path" ]; then
        $op "$path"
        [ $op = cd ] && pwd
    fi
}

# Completion function for pcd
_pcdcomp() {
    [ "$1" != pcd ] && return 1
    COMPREPLY=()

    # Current word being completed
    local word=${COMP_WORDS[$COMP_CWORD]}
    # IFS must be set to a single newline so compgen suggestions with spaces
    # work
    local IFS=$'\n' pdir_idx= sdir_idx= i comp_opt=$(compgen -W '-p' -- "$word")

    # Scan command line state
    for ((i=1; i<${#COMP_WORDS[*]}; i++)); do
        if [ "${COMP_WORDS[$i]:0:1}" != - ]; then
            [ -z "$pdir_idx" ] && pdir_idx=$i && continue
            [ -z "$sdir_idx" ] && sdir_idx=$i
        elif [ "${COMP_WORDS[$i]}" = '-p' -a $i -ne $COMP_CWORD ]; then
            comp_opt=
        fi
    done

    # By default, all completions are suffixed with a space, so cursor jumps to
    # next command argument when a completion is selected uniquely, except for
    # the project subdir argument. We handle this manually, since adjusting the
    # 'nospace' option dynamically with compopt has proven to be unreliable.
    local add_space_to_completions=1
    
    # Provide completions according to command line state
    if [ $COMP_CWORD = ${pdir_idx:--1} ]; then
        # State: project argument
        
        if [ "${word:0:1}" = . ]; then
            COMPREPLY=('..')
        else
            COMPREPLY=($(cd "$PROJECTS_PATH" && compgen -X \*.git -d -- "$word"))
        fi
        if [ "$comp_opt" ]; then
            COMPREPLY+=("$comp_opt")
        fi
    elif [ $COMP_CWORD = ${sdir_idx:--1} ]; then
        # State: project subdir argument
        
        local project_root="$PROJECTS_PATH"/"${COMP_WORDS[$pdir_idx]}" git_root
        if [ "${COMP_WORDS[$pdir_idx]}" = .. ]; then
            git_root=$(git rev-parse --show-toplevel 2>/dev/null) && project_root=$git_root
        fi
        
        COMPREPLY=($(cd "$project_root" 2>/dev/null && compgen -X \*.git -S/ -d -- "$word"))
        if [ ${#COMPREPLY[*]} -gt 0 ]; then
            # Avoid space after subdir argument, to allow for drilling while
            # completing
            add_space_to_completions=
        elif [ -z "$word" ]; then
            # No available subdirs for selected project and empty current arg,
            # offer '.' and options
            COMPREPLY=('.')
            if [ "$comp_opt" ]; then
                COMPREPLY+=("$comp_opt")
            fi
        fi
    elif [ "$comp_opt" ]; then
        # State: end of regular args or other
        
        COMPREPLY+=("$comp_opt")
    fi
    
    # Post process, do shell safe name quoting and possibly add space to each
    # completion:
    for ((i=0; i<${#COMPREPLY[*]}; i++)); do
        COMPREPLY[$i]=$(printf "%q${add_space_to_completions:+ }" "${COMPREPLY[$i]}")
    done
}

# Bind completion function to command:
complete -o nospace -F _pcdcomp pcd
