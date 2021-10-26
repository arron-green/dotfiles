#!/usr/bin/env bash

# adding this here since profile wont be sourced if ~/.bash_profile exists
[ -e $HOME/.profile ] && source $HOME/.profile

if [ -e /Users/arrongreen/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/arrongreen/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
