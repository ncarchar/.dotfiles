#!/bin/sh

# Only run for interactive shells
[[ $- == *i* ]] || return

export PATH="$HOME/.scripts:$PATH"
export PATH="/home/cvhew/.local/bin:$PATH"

source ~/.shell/alias.sh
source ~/.shell/fzfconf.sh

if [[ "$(uname -s)" != "Darwin" ]]; then
    source ~/.shell/bleconf.sh
fi

bind 'set show-all-if-ambiguous on'

# disable shell exit on Ctrl+d
export IGNOREEOF=999

# history
shopt -s histappend
HISTFILESIZE=5000
HISTCONTROL=ignorespace:ignoredups
HISTTIMEFORMAT="%F %T "

# Scale QT & GDK Apps
export QT_SCALE_FACTOR=1.4
export GDK_SCALE=1.0
export GDK_DPI_SCALE=1.4

# direnv
eval "$(direnv hook bash)"

# prompt
eval "$(starship init bash)"

# manually alias zoxide
export _ZO_ECHO=1
eval "$(zoxide init bash --no-cmd)"
alias z="__zoxide_z"

# atuin history
eval "$(atuin init bash --disable-up-arrow)"

if [[ $HOSTNAME == COV* ]]; then
    alias ps-copy="/mnt/c/WINDOWS/system32/clip.exe"
    alias claude='AWS_PROFILE=bedrock claude'
    export BROWSER="/mnt/c/Users/CVHEW/AppData/Local/Mozilla Firefox/firefox.exe"
    export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=$HOME/.certs-java/ca-trust.p12 -Djavax.net.ssl.trustStorePassword=changeit"
    export COV=1
    export wstore=/mnt/c/Store
    export whome=/mnt/c/Users/CVHEW

    ssm-rds() {
        if [[ -z "$1" || -z "$2" ]]; then
            echo "Usage: ssm-rds <profile> <region> [local_port]"
            echo "  profile     AWS profile name (e.g. omd-dev)"
            echo "  region      AWS region (e.g. us-east-1)"
            echo "  local_port  Local port to forward (default: 5432)"
            return 1
        fi

        local profile="$1"
        local region="$2"
        local local_port="${3:-5432}"

        local instance_id_param=$(aws configure get bastion_instance_id --profile "$profile")
        local rds_host_param=$(aws configure get rds_host --profile "$profile")

        local instance_id=$(
            aws ssm get-parameter \
                --name "$instance_id_param" \
                --query "Parameter.Value" \
                --output text \
                --profile "$profile" \
                --region "$region"
        )

        local rds_host=$(
            aws ssm get-parameter \
                --name "$rds_host_param" \
                --query "Parameter.Value" \
                --output text \
                --profile "$profile" \
                --region "$region"
        )

        echo "instance_id: $instance_id"
        echo "rds_host: $rds_host"

        aws ssm start-session \
            --target "$instance_id" \
            --document-name AWS-StartPortForwardingSessionToRemoteHost \
            --parameters "{\"host\":[\"$rds_host\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"$local_port\"]}" \
            --profile "$profile" \
            --region "$region"

    }

    ssm-rds-kill() {
        if [[ -z "$1" || -z "$2" ]]; then
            echo "Usage: ssm-rds-kill <profile> <region>"
            echo "  profile     AWS profile name (e.g. omd-dev)"
            echo "  region      AWS region (e.g. us-east-1)"
            return 1
        fi

        local profile="$1"
        local region="$2"

        local instance_id_param=$(aws configure get bastion_instance_id --profile "$profile")

        local instance_id=$(
            aws ssm get-parameter \
                --name "$instance_id_param" \
                --query "Parameter.Value" \
                --output text \
                --profile "$profile" \
                --region "$region"
        )

        echo "Terminating active SSM sessions for instance: $instance_id"

        aws ssm describe-sessions \
            --state Active \
            --filters "key=Target,value=$instance_id" \
            --query "Sessions[*].SessionId" \
            --output text \
            --profile "$profile" \
            --region "$region" \
        | tr '\t' '\n' \
        | xargs -I{} aws ssm terminate-session \
            --session-id {} \
            --profile "$profile" \
            --region "$region"
    }

fi
