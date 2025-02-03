export COV=true

export CHROME_BIN=/usr/bin/chromium-browser
export BROWSER="/mnt/c/Users/cvhew/AppData/Local/Mozilla Firefox/firefox.exe"
export PATH="$PATH:/opt/nvim-linux64/bin"

source "$HOME/.sdkman/bin/sdkman-init.sh"
alias sjava21="sdk use java 21.0.2-amzn"
alias sjava17="sdk use java 17.0.10-amzn"
alias sjava8="sdk use java 8.0.412-amzn"

export PATH=$JAVA_HOME/bin:$PATH

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
