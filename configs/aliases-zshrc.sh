#!/usr/bin/env zsh

# https://wiki.archlinux.org/title/zsh
# When starting, Zsh will read commands from the following files in 
# this order by default, provided they exist.

# /etc/zsh/zshenv: system-wide .zshenv file for zsh(1).
# /etc/zsh/zprofile: system-wide .zprofile file for zsh(1).
  # /etc/profile: system-wide .profile file for the Bourne shell (sh(1))

# $ZDOTDIR/.zprofile Used for executing user's commands at start

# /etc/zsh/zshrc: system-wide .zshrc file for zsh(1).
# /etc/zsh/zlogin: system-wide .zlogin file for zsh(1).

# /etc/zsh/zlogout: system-wide .zlogout file for zsh(1).

# Configuring $PATH

# Zsh ties the PATH variable to a path array. This allows you to 
# manipulate PATH by simply modifying the path array. 
# See A User's Guide to the Z-Shell for details.

# To add ~/.local/bin/ to the PATH:

# ~/.zshenv
# typeset -U path PATH
# path=(~/.local/bin $path)
# export PATH

if [ -f ~/.aliases_common ]; then
  . ~/.aliases_common
fi

# zsh_colors() {
#   print -P '%B%F{red}co%F{green}lo%F{blue}rs%f%b'
# }


# ~/.bash_profile to ~/.zprofile

# apt update && sudo apt upgrade && sudo apt autoremove

# check for version/system
# check for versions (compatibility reasons)
function is4 () {
  [[ $ZSH_VERSION == <4->* ]] && return 0
  return 1
}

# Set a shell option but don't fail if it doesn't exist!
safe_set() {
  setopt -s "$1" >/dev/null 2>&1 || true;
}

# # Configure the history to make it large and support multi-line commands.
# safe_set histappend                  # Don't overwrite the history file, append.
# safe_set cmdhist                     # Multi-line commands are one entry only.

# append history list to the history file; this is the default but we make sure
# because it's required for share_history.
setopt append_history           # append

# import new commands from the history file also in other zsh-session
# is4 && 
setopt share_history            # share hist between sessions

# save each command's beginning timestamp and the duration to the history file
setopt extended_history

# If a new command line being added to the history list duplicates an older
# one, the older command is removed from the list
# is4 && 
setopt histignorealldups
# setopt hist_ignore_all_dups     # no duplicate

# remove command lines from the history list when the first character on the
# line is a space
setopt histignorespace          # ignore space prefixed commands
setopt hist_reduce_blanks       # trim blanks
# setopt inc_append_history       # add commands as they are typed, don't wait until shell exit
setopt hist_verify              # show before executing history commands

# # if a command is issued that can't be executed as a normal command, and the
# # command is the name of a directory, perform the cd command to that directory.
# setopt auto_cd

# in order to use #, ~ and ^ for filename generation grep word
# *~(*.gz|*.bz|*.bz2|*.zip|*.Z) -> searches for word not in compressed files
# don't forget to quote '^', '~' and '#'!
# setopt extended_glob

# display PID when suspending processes as well
setopt longlistjobs

# report the status of backgrounds jobs immediately
setopt notify

# # whenever a command completion is attempted, make sure the entire command path
# # is hashed first.
# setopt hash_list_all

# # not just at the end
# setopt completeinword

# # Don't send SIGHUP to background processes when the shell exits.
# setopt nohup

# # make cd push the old directory onto the directory stack.
# setopt auto_pushd

# # avoid "beep"ing
# setopt nobeep

# # don't push the same dir twice.
# setopt pushd_ignore_dups

# # * shouldn't match dotfiles. ever.
# setopt noglobdots

# # use zsh style word splitting
# setopt noshwordsplit

# # don't error out when unset parameters are used
# setopt unset

setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass.