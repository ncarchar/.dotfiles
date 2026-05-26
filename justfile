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

update:
    nix flake update --flake "path:./nix"

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
        check="$(date -u +%Y%m%d-%H%M%S) $(hostname)"; \
    	echo "committing to git..."; \
    	git add .; \
    	git commit -m "$check"; \
    	git push origin; \
    	echo "complete..."; \
    else \
    	echo "nothing to commit..."; \
    fi
