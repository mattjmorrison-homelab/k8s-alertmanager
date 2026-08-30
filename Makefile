.PHONY: check

check:
	nix shell nixpkgs#kubernetes-helm nixpkgs#bats nixpkgs#yq-go -c bats manifests/tests
