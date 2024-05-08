.PHONY: timewarp
timewarp:
	nixos-rebuild switch --flake ./#TimeWarp
