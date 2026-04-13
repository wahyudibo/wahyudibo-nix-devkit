#!/usr/bin/env bash

nix run home-manager/master -- switch --flake .#wahyudibo
exec zsh -l
