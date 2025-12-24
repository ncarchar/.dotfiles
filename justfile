default:
    just -l

main:
    sudo nixos-rebuild switch --flake "path:./nix#nixos"
    just _commit

cov:
    home-manager switch --flake "./nix#cvhew"
    just _commit

mac:
    home-manager switch --flake "./nix#mac"
    just _commit

gc:
    nix-collect-garbage -d

gc-sys:
    sudo nix-collect-garbage -d

list-gen:
    sudo nix-env -p /nix/var/nix/profiles/system --list-generations

stow:
    find ~/.dotfiles/home -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | xargs -I {} stow -d ~/.dotfiles/home -t ~ -v -R {}

ansible:
    ansible-playbook ./ansible/main.yml --ask-vault-pass --ask-become-pass

_commit:
    if [ -n "$(git status --porcelain)" ]; then \
    	check=$(git ls-tree -r HEAD | md5sum | awk '{print $1}'); \
    	echo "Committing to Git..."; \
    	git add .; \
    	git commit -m "$check __"; \
    	git push origin; \
    	echo "Complete..."; \
    else \
    	echo "No changes - nothing to commit..."; \
    fi
