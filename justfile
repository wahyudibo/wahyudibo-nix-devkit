apply:
	nix run home-manager/master -- switch --flake .#wahyudibo
	exec zsh -l

update:
	nix flake update

clean:
	nix-collect-garbage -d

rebuild: update apply

doctor:
	nix doctor || true
