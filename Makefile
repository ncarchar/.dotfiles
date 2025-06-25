.PHONY: diff nixos cov darwin commit

diff:
	git --no-pager diff -U0

nixos:
	sudo nixos-rebuild switch --flake "path:./nixos#nixos"
	nixos-rebuild list-generations | grep current
	@$(MAKE) _commit

cov:
	LOAD_CERTS=0 home-manager switch --flake "./nixos#cvhew" --extra-experimental-features "nix-command flakes"
	@$(MAKE) _commit

darwin:
	LOAD_CERTS=0 home-manager switch
	@$(MAKE) _commit

_commit:
	@if [ -n "$$(git status --porcelain)" ]; then \
		check=$$(git ls-tree -r HEAD | md5sum | awk '{print $$1}'); \
		@echo "Committing to Git..."; \
		git add .; \
		git commit -m "$$check __"; \
		git push origin; \
		@echo "Commit and push complete..."; \
	else \
		@echo "No changes - nothing to commit..."; \
	fi
