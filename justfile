default:
    just -l

main:
    sudo nixos-rebuild switch --flake "path:./nix#nixos"
    just _pi-settings main
    just _commit

cov:
    home-manager switch --flake "./nix#cvhew"
    just _pi-settings cov
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
    # Keep pi's runtime dir real so stow folds the *tracked subdirs*
    # (extensions/, skills/, …) into symlinks instead of folding ~/.pi/agent
    # itself. If agent is ever empty when stow runs, stow folds it into one
    # symlink and runtime state (git/, npm/, auth.json) leaks into the repo.
    mkdir -p ~/.pi/agent/sessions
    find ~/.dotfiles/home -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | xargs -I {} stow -d ~/.dotfiles/home -t ~ -v -R {}

ansible:
    ansible-playbook ./ansible/main.yml --ask-vault-pass --ask-become-pass

# Build ~/.pi/agent/settings.json as { ...live, ...base, ...host }. Pi owns the
# live file (runtime keys like hideThinkingBlock), the repo layers win.
# shortcut: shallow merge, nested objects are replaced; use `jq -s '.[0] * .[1] * .[2]'` if needed.
_pi-settings host:
    #!/usr/bin/env bash
    set -euo pipefail
    f=~/.pi/agent/settings.json
    src=~/.dotfiles/home/_pi/settings
    [ -L "$f" ] && { cp --remove-destination -L "$f" "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" || rm -f "$f"; }
    [ -f "$f" ] || echo '{}' > "$f"
    jq -s 'add' "$f" "$src/settings.base.json" "$src/settings.{{host}}.json" > "$f.tmp"
    mv "$f.tmp" "$f"

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
