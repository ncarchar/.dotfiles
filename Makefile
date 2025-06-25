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

stow:
	find ~/.dotfiles/home -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | xargs -I {} stow -d ~/.dotfiles/home -t ~ -v -R {}

ansible:
	ansible-playbook ./ansible/main.yml --ask-vault-pass --ask-become-pass

_commit:
	@if [ -n "$$(git status --porcelain)" ]; then \
		check=$$(git ls-tree -r HEAD | md5sum | awk '{print $$1}'); \
		echo "Committing to Git..."; \
		git add .; \
		git commit -m "$$check __"; \
		git push origin; \
		echo "Commit and push complete..."; \
	else \
		echo "No changes - nothing to commit..."; \
	fi
