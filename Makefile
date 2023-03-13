
.PHONY: nix-rust
nix-rust:
	@nix build

.PHONY: docker
docker:
	@nix build '.#docker'
	@docker load < result

.PHONY: docker-run
docker-run:
	@docker run nix-rust

.PHONY: nix-run
nix-run:
	@nix run
