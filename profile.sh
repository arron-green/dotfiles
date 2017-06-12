if [ ! -d ~/.virtualenvs ]; then
    export WORKON_HOME="~/.virtualenvs"
fi
type -p virtualenvwrapper.sh > /dev/null 2>&1 && source $(type -p virtualenvwrapper.sh)

# adds color to my terminal
export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
case $TERM in
     xterm*|rxvt*)
         TITLEBAR='\[\033]0;\u ${NEW_PWD}\007\]'
          ;;
     *)
         TITLEBAR=""
          ;;
    esac
export COLOR_NIL='\[\033[00m\]'
export COLOR_RED='\[\033[31m\]'
export COLOR_GREEN='\[\033[32m\]'
export COLOR_BLUE='\[\033[34m\]'
export COLOR_CYAN='\[\033[36m\]'

function ps1-prompt() {
    # current working directory
    PS1_PREFIX="${COLOR_GREEN}\W${COLOR_NIL}"

    # git info
    export GIT_PS1_SHOWCOLORHINTS=true
    GIT_PS=$(__git_ps1 "%s")
    if [[ ! -z $GIT_PS ]]; then
      if [ "$(is-git-dirty)" == "1" ]; then
          GIT=" (${COLOR_RED}${GIT_PS}${COLOR_NIL})"
      else
          GIT=" (${GIT_PS})"
      fi
    else
      GIT=""
    fi

    # python specific
    VENV=""
    [[ ! -z $VIRTUAL_ENV ]] && VENV=" [${COLOR_BLUE}V${COLOR_NIL}]"

    END="${COLOR_BLUE}\$${COLOR_NIL} "
    export PS1="${PS1_PREFIX}${VENV}${GIT} ${END}"
}
export PROMPT_COMMAND=ps1-prompt

# tab completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
   . $(brew --prefix)/etc/bash_completion
fi
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" scp
type -p aws_completer > /dev/null 2>&1 && complete -C "$(type -p aws_completer)" aws

# utility functions
function find-scala-home {
  local source="`type -p scala`"
  while [ -h "$source" ] ; do
    local linked="$(readlink "$source")"
    local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
    source="$dir/$(basename "$linked")"
  done
  ( cd -P "$(dirname "$source")/.." && pwd )
}

function is-git-dirty {
      if git update-index -q --refresh 2>/dev/null; git diff-index --quiet --cached HEAD --ignore-submodules -- 2>/dev/null && git diff-files --quiet --ignore-submodules 2>/dev/null; then
          echo ""
      else
          echo 1
      fi
}

function is-git {
    git branch >/dev/null 2>&1
    exit $?
}

function gg {
    if [ is-git ]; then
        git status
    fi
}

function git-branch {
    git branch >/dev/null 2>&1
    RETURN_CODE=$?
    if [ "$RETURN_CODE" == "0" ]; then
        git rev-parse --abbrev-ref HEAD
    fi
    exit $RETURN_CODE
}

function git-branch-cp {
    BN=`git-branch`
    if [ "$?" == "0" ]; then
        echo "$BN" | tr -d '\n' | pbcopy
    fi
}

function notify {
  start=$(date +%s)
  $*
  end=$(date +%s)
  terminal-notifier -message "$*" -title done -subtitle "$(($end - $start)) seconds"
}

# Docker specific
function docker-init {
  NAME="$1"
  MEMORY="${2-1024}"
  if [ ! -z $NAME ]; then
      STATUS=`docker-machine status $NAME`
      if [ "$?" == "0" ]; then
          if [ "$STATUS" == "Stopped" ]; then
              docker-machine start $NAME
          fi
      else
          docker-machine create -d virtualbox --virtualbox-disk-size "40000" --virtualbox-memory "$MEMORY" $NAME
      fi
      docker-machine env $NAME
      # eval "$(docker-machine env $NAME)"
  fi
}

function epoch-to-human {
  EPOCH="$1"
  if [ ! -z $EPOCH ]; then
      gdate -d @$EPOCH +'%F %r %Z'
  fi
}

#AWS specific
function aws-log-groups {
    aws logs describe-log-groups | jq -r -c '.logGroups[] .logGroupName'
}

function aws-terminate-instance-by-id {
  INSTANCE_ID=$1
  if [ ! -z $INSTANCE_ID ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
  else
    echo "usage: $0 [instance-ids]"
  fi
}

function aws-reset-password {
  USERNAME="${1}"
  read -s -p "Password: " PASS
  if [ ! -z $PASS ]; then
      aws iam update-login-profile --user-name $USERNAME --password $PASS
      if [ "$?" == "0" ]; then
          echo "Password changed for $USERNAME"
      else
          echo "Error\! update-login-profile returned non zero status"
      fi
  else
      echo "Usage: $0 '[password]' '[username]'"
  fi
}

function aws-change-password {
    read -s -p "Old Password: " OLD_PASS
    echo "Ok... got the old"
    read -s -p "New Password: " NEW_PASS
    echo "Ok... got the new"
    if [[ ! -z $OLD_PASS && ! -z $NEW_PASS ]]; then
        aws iam change-password --old-password "${OLD_PASS}" --new-password "${NEW_PASS}"
        if [ "$?" == "0" ]; then
            echo "Password changed"
            return 0
        else
            echo "ERROR: Non zero result returned. Possible password policy issue?"
            return 1
        fi
    else
        echo "The old and new password cannot be blank"
        return 1
    fi
}

function aws-cfn-watch-stack {
    STACK_NAME=${1}
    REFRESH=${2-1}
    if [ ! -z $STACK_NAME ]; then
        WATCH_CMD="aws cloudformation describe-stack-events --stack-name $STACK_NAME | jq -rc '.StackEvents | map(select(. != null)) | .[] | [.Timestamp, .ResourceType, .ResourceStatus, .ResourceStatusReason]'"
        watch -n$REFRESH $WATCH_CMD
    else
        echo "Usage: cfn-watch-stack [STACK-NAME] [REFRESH]"
    fi
}

function aws-cfn-outputs {
    STACK_NAME=${1}
    if [ ! -z $STACK_NAME ]; then
        JSON=$(aws cloudformation describe-stacks --stack-name $STACK_NAME)
        [ $? == 0 ] && echo $JSON | jq -rc '.Stacks[] .Outputs | map({key: .OutputKey, value: .OutputValue}) | from_entries'
    else
        echo "Usage: cfn-outputs [STACK-NAME]"
    fi
}

function aws-cfn-params {
    STACK_NAME=${1}
    if [ ! -z $STACK_NAME ]; then
        JSON=$(aws cloudformation describe-stacks --stack-name $STACK_NAME)
        [ $? == 0 ] && echo $JSON | jq -rc '.Stacks[] .Parameters | map({key: .ParameterKey, value: .ParameterValue}) | from_entries'
    else
        echo "Usage: cfn-outputs [STACK-NAME]"
    fi
}

function aws-disable-mfa {
    MFA_DEVICES=$(aws iam list-mfa-devices | jq -rc '.MFADevices')
    MFA_COUNT=$(echo $MFA_DEVICES | jq -rc 'length')
    if [ $MFA_COUNT -gt 0 ]; then
        USER_NAME=$(echo $MFA_DEVICES | jq -rc '.[] .UserName')
        SERIAL_NUM=$(echo $MFA_DEVICES | jq -rc '.[] .SerialNumber')
        if [ -z $USER_NAME ] && [ -z $SERIAL ]; then
            aws iam deactivate-mfa-device --user-name "$USER_NAME" --serial-number "$SERIAL_NUM"
        fi
    fi
}

function aws-enable-mfa {
    USER=${1}
    SERIAL_NUM=$(aws iam list-virtual-mfa-devices | jq -rc ".VirtualMFADevices | map(select(.SerialNumber | contains(\"$USER\"))) | .[] .SerialNumber")
}

export JAVA_HOME=`/usr/libexec/java_home`

# default to scala 2.11
BREW_SCALA_HOME="$(brew --prefix)/opt/scala@2.11"
if [[ -d "${BREW_SCALA_HOME}/bin" ]]; then
    export PATH="${BREW_SCALA_HOME}/bin:$PATH"
    export SCALA_HOME="$(find-scala-home)"
fi

export PATH="$HOME/.bin:/usr/local/sbin:$PATH"

if [[ -d $HOME/.conscript ]]; then
    export CONSCRIPT_HOME="$HOME/.conscript"
    export PATH="$PATH:$HOME/.conscript/bin"
fi

export PATH="/usr/local/opt/openssl/bin:$PATH"

# export LDFLAGS="-L/usr/local/opt/openssl/lib -L/usr/local/lib -L/usr/local/opt/openldap/lib"
# export CPPFLAGS="-I/usr/local/opt/openssl/include -I$(xcrun --show-sdk-path)/usr/include/sasl -I/usr/local/include"
# export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

# NOTE: required to compile rust-openssl
export OPENSSL_INCLUDE_DIR="/usr/local/opt/openssl/include"
export DEP_OPENSSL_INCLUDE="$OPENSSL_INCLUDE_DIR"

export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I$OPENSSL_INCLUDE_DIR"
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"

# ZEPPELIN SPECIFIC
if [[ -d $HOME/.zeppelin-conf ]]; then
    export ZEPPELIN_CONF_DIR="$HOME/.zeppelin-conf"
fi

# export LDFLAGS=-L/usr/local/opt/readline/lib
# export CPPFLAGS=-I/usr/local/opt/readline/include

# nodejs specific
export BREW_NVM_HOME="$(brew --prefix)/opt/nvm"
if [[ -d $BREW_NVM_HOME ]]; then
    [[ -d "$HOME/.nvm" ]] || echo mkdir -p "$HOME/.nvm"
    source "$BREW_NVM_HOME/nvm.sh"
fi


alias "certs-show-csr"='openssl req -noout -text -in '
alias "certs-show-key"='openssl rsa -noout -text -in '
alias "certs-show-pem"='openssl x509 -noout -text -in '
alias "certs-show-sig"='openssl pkcs7 -inform der -noout -text -print_certs -in '
alias urldecode='python -c "import sys, urllib as ul; \
  print ul.unquote_plus(sys.argv[1])"'
alias urlencode='python -c "import sys, urllib as ul; \
    print ul.quote_plus(sys.argv[1])"'
alias gpg='gpg1'
alias stripcolors='gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'

