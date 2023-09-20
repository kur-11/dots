# {{{ minimal settings

ttyctl -f

bindkey -d

clear_screen_and_scrollback() {
    echoti civis > "$TTY"
    printf '%b' '\e[H\e[2J' > "$TTY"
    zle .reset-prompt
    zle -R
    printf '%b' '\e[3J' > "$TTY"
    echoti cnorm > "$TTY"
}

zle -N clear_screen_and_scrollback
bindkey '' clear_screen_and_scrollback

autoload smart-insert-last-word
zle -N insert-last-word smart-insert-last-word

autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars ' _-./:;@?='
zstyle ':zle:*' word-style unspecified

alias relogin='exec $SHELL -l'

unset HISTFILE
export HISTSIZE=0

typeset -U path cdpath

path=(
    ~/bin(N-/)
    $path
)

cdpath=(
    ~
    ~/src(N-/)
    ~/GitHub(N-/)
    ~/Projects(N-/)
    $cdpath
)

autoload -Uz compinit
compinit

() {
    if (( $+commands[git] )); then
        local gitdir=~/.dotfiles worktree=~
        alias dotfiles="git --git-dir=$gitdir --work-tree=$worktree"
        compdef dotfiles=git
        git --git-dir=$gitdir rev-parse --is-inside-work-tree &>/dev/null \
            || git init --bare $gitdir
    fi
}

# dotfiles-commit-auto() {
#     local modified=($(dotfiles diff --name-only)) x
#     for x in $modified; do
#         dotfiles diff -- $x
#     done
# }

[[ $TERM != linux ]] || return 0

# }}}

# {{{ tmux

if (( $+commands[tmux] && ! $+TMUX && $+SSH_CONNECTION )); then
    tmux has && exec tmux attach
    exec tmux new
fi

# }}}

# {{{ zsh-snap

() {
    local znapdir=~/.znap
    [[ -f $znapdir/znap.zsh ]] \
        || git clone --depth=1 https://github.com/marlonrichert/zsh-snap.git $znapdir
    . $znapdir/znap.zsh
    zstyle ':znap:*' repos-dir $znapdir/repos
}

# }}}

# {{{ zsh-users

znap source zsh-users/zaw
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting

# }}}

# {{{ prezto

# arch: pkgfile

znap source sorin-ionescu/prezto modules/{command-not-found,completion}

# }}}

# {{{ asdf

znap source asdf-vm/asdf asdf.sh

# }}}

# {{{

export PURE_PROMPT_SYMBOL='›'
export PURE_PROMPT_VICMD_SYMBOL='‹'
znap source kur-11/pure async.zsh pure.zsh

# }}}

# {{{

setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=$((HISTSIZE * 365))

typeset -TUx HISTORY_IGNORE history_ignore '|'
history_ignore+=('history' 'history *')

my_zshaddhistory() {
    local r="($HISTORY_IGNORE)"
    [[ $1 != ${~r} ]]
}

autoload -Uz add-zsh-hook

add-zsh-hook zshaddhistory my_zshaddhistory

alias history='fc -lDi'

bindkey '' history-beginning-search-backward
bindkey '' history-beginning-search-forward

# }}}

# {{{

ipv4() { curl -fsS https://api.ipify.org; echo }

ipv6() { curl -fsS https://api64.ipify.org; echo }

mkcd() { install -Ddv "$1" && cd "$1" }

# }}}

# {{{

alias ls='ls -Xv --color=auto --group-directories-first'
alias cp='cp -v'
alias mv='mv -v'
alias grep='grep --color=auto'

# }}}

# {{{ rust

if (( $+commands[cargo] )); then
    path+=(~/.cargo/bin(N-/))
fi

# }}}

# {{{ go

if (( $+commands[go] )); then
    export GOPATH=~/.go
    path+=($GOPATH/bin)
fi

# }}}

# {{{ emacs

if (( $+commands[emacsclient] )); then
    alias emacs='emacsclient -t'
fi

# }}}

# {{{

is_linux=0 is_osx=0
case $OSTYPE in
    linux*) islinux=1 ;;
    darwin*) isosx=1 ;;
esac

if (( $isosx )); then
    alias reset-launchpad='defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock'
fi

# }}}

# {{{ source and compile

__zcompile() {
    local src=$1 zwc=$1.zwc
    [[ ! -f $zwc || $src -nt $zwc ]] \
        && zcompile $src
}

__zcompile ~/.zshrc

setopt NULL_GLOB
setopt EXTENDED_GLOB

() {
    while (( $# )); do
        __zcompile $1
        . $1
        shift
    done
} ~/.zshrc.*~*.zwc~*\~

# }}}
