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

# {{{ disable history

unset HISTFILE
export HISTSIZE=0

# }}}

# {{{ environment variables

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

# }}}

# {{{ dotfiles

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

# }}}

# {{{ ssh-agent

if (( $+commands[ssh-agent] )); then
    if ! pgrep -u $USER ssh-agent > /dev/null; then
        ssh-agent > ~/.ssh-agent-thing
    fi
    if (( ! $+SSH_AGENT_PID )); then
        eval "$(< ~/.ssh-agent-thing)" > /dev/null
    fi
    alias ssh='ssh-add -l > /dev/null || ssh-add && unalias ssh; ssh'
fi

# }}}

# {{{ return if console

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

# {{{ prompt

export PURE_PROMPT_SYMBOL='›'
export PURE_PROMPT_VICMD_SYMBOL='‹'
znap source kur-11/pure async.zsh pure.zsh

# }}}

# {{{ history

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
    path=(~/.cargo/bin(N-/) $path)
fi

# }}}

# {{{ go

if (( $+commands[go] )); then
    export GOPATH=~/.go
    path=($GOPATH/bin(N-/) $path)
fi

# }}}

# {{{ emacs

if (( $+commands[emacsclient] )); then
    alias emacs='emacsclient -t'
fi

# }}}

# {{{ nnn

if (( $+commands[nnn] )); then
    export NNN_OPTS=aBdoRS

    typeset -TUx NNN_BMS nnn_bms ;
    nnn_bms=(
        m:~/.config/nnn/mounts
        M:/run/media/$USER
    )

    typeset -TUx NNN_PLUG nnn_plug ;
    nnn_plug=()

    typeset -TUx NNN_ORDER nnn_order ;
    nnn_order=(t:/)

    export RCLONE='rclone mount --'

    if (( $+commands[trash] )); then
        export NNN_TRASH=1
    fi
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
