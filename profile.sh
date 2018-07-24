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
export EDITOR=$(command -v vim)

function echo-err() {
    printf "%s\n" "$*" >&2;
}

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
    if [[ ! -z $VIRTUAL_ENV ]]; then
        VENV=" [${COLOR_BLUE}${PYENV_VERSION-V}${COLOR_NIL}]"
    fi

    END="${COLOR_GREEN}\$${COLOR_NIL} "
    export PS1="${PS1_PREFIX}${VENV}${GIT} ${END}"
}
export PROMPT_COMMAND=ps1-prompt
BREW_PREFIX=$(brew --prefix)

# bash history overrides
export HISTCONTROL=ignoreboth # dont record commands that start with a space or commands that already exist
export HISTSIZE=4000 # default is 500

# tab completion
[[ -f ${BREW_PREFIX}/opt/bash-completion/etc/bash_completion ]] && source ${BREW_PREFIX}/opt/bash-completion/etc/bash_completion
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

function pip-remove-globals {
    while read P; do
        pip uninstall -y $P;
    done < <(pip list --format=json | jq -rc '.[] .name' | egrep -v 'pip|setuptools|wheel|six')
}

function notify {
  start=$(date +%s)
  $*
  end=$(date +%s)
  terminal-notifier -message "$*" -title done -subtitle "$(($end - $start)) seconds"
}

# Kubernetes specific
function minikube-dns {
  # Remove any existing routes
  sudo route -n delete 10/24 > /dev/null 2>&1

  # Create route
  sudo route -n add 10.0.0.0/24 $(minikube ip)
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

function docker-image-grep {
  QUIET=false
  while [[ $# -gt 0 ]] && [[ ."$1" = .--* ]] ;do
      opt="$1"; shift;
      case "$opt" in
          "--" ) break 2;;
          "--image" )
              IMAGE="$1"; shift;;
          "--image="* )     # alternate format: --first=date
              IMAGE="${opt#*=}";;
          "-q" )
              QUIET=true;;
          "--quiet" )
              QUIET=true;;
          *) echo >&2 "Invalid option: $@";
              return 1;;
      esac
  done

  JSON=$(docker images --format '{{json .}}' | jq --arg IMAGE $IMAGE -rc 'select(.Repository | test($IMAGE))')
  if [[ "$?" == "0" ]]; then
      if [[ "$QUIET" == "true" ]]; then
          echo $JSON | jq -rc '.ID' | xargs
      else
          echo $JSON | jq -rc .
      fi
  fi
}

function epoch-to-human {
  EPOCH="$1"
  if [ ! -z $EPOCH ]; then
      gdate -d @$EPOCH +'%F %r %Z'
  fi
}
function randUuid {
  # only because a stupid ruby gem is first in my path
  /usr/local/bin/uuid
}

alias "iso8601-now"="gdate +%Y-%m-%dT%H:%M:%S%z"
alias "iso8601-now-utc"="gdate -u +%Y-%m-%dT%H:%M:%S%z"

#AWS specific
function aws-profiles {
    CREDS=$HOME/.aws/credentials
    if [ -e $CREDS ]; then
        while read PROFILE; do
            echo export AWS_PROFILE=$PROFILE
        done < <(ack '\[(?<p>.+)\]' $CREDS --output '$+{p}')
    else
        echo "$CREDS does not exist"
        return 1
    fi
}

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

function ack-json-log {
    ack '^<\d+>\d+-\d+-\d+T\d+:\d+:\d+Z\s[\w-]+\s[\w\(\)\[\]-]+:\s(?<json>\{.+\})$' --output '$+{json}' $@
}

export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export GRADLE_HOME="${BREW_PREFIX}/opt/gradle"

# default to scala 2.11
BREW_SCALA_HOME="${BREW_PREFIX}/opt/scala@2.11"
if [[ -d "${BREW_SCALA_HOME}/bin" ]]; then
    export PATH="${BREW_SCALA_HOME}/bin:$PATH"
    export SCALA_HOME="$(find-scala-home)"
fi

export PATH="$HOME/.bin:/usr/local/sbin:$PATH"

if [[ -d $HOME/.local ]]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

if [[ -d $HOME/.conscript ]]; then
    export CONSCRIPT_HOME="$HOME/.conscript"
    export PATH="$PATH:$HOME/.conscript/bin"
fi

export OPENSSL_HOME="${BREW_PREFIX}/opt/openssl"
export PATH="$OPENSSL_HOME/bin:$PATH"

export CONFLUENT_VERSION="4.1.1"
# export CONFLUENT_VERSION="4.1.0"
export CONFLUENT_SCALA_VERSION="2.11"
export CONFLUENT_HOME="/usr/local/confluent-${CONFLUENT_VERSION}"
if [[ -d ${CONFLUENT_HOME}/bin ]]; then
    export PATH="$PATH:${CONFLUENT_HOME}/bin"
fi

function confluent-install {
    if [[ -d $CONFLUENT_HOME ]]; then
        echo "confluent kafka already installed"
        return 0
    else
        CONFLUENT_ZIP="confluent-oss-${CONFLUENT_VERSION}-${CONFLUENT_SCALA_VERSION}.zip"
        CONFLUENT_TMP="/tmp/${CONFLUENT_ZIP}"
        CONFLUENT_DL="http://packages.confluent.io/archive/${CONFLUENT_VERSION%.*}/${CONFLUENT_ZIP}"
        if [[ ! -f "${CONFLUENT_TMP}" ]]; then
            curl -L -o "${CONFLUENT_TMP}" "${CONFLUENT_DL}"
        fi

        unzip "${CONFLUENT_TMP}" -d /tmp
        sudo mv "/tmp/confluent-${CONFLUENT_VERSION}" "/usr/local/"
    fi
}

function mk-kafka-topic-compact {
    TOPIC=${1}
    if [ ! -z ${TOPIC} ]; then
        kafka-topics \
            --zookeeper localhost:2181 \
            --create \
            --topic "${TOPIC}" \
            --replication-factor 1 \
            --partitions 1 \
            --config cleanup.policy=compact
    else
        echo "usage: ${0} [topic]"
        return 1
    fi
}

function pid-of-port {
    PORT=${1}
    if [ -z $PORT ]; then
        echo "usage: ${0} [port]"
        return 1
    else
        lsof -i:${PORT} -t
    fi
}

if [[ -d $BREW_PREFIX/opt/curl/bin ]]; then
    export PATH="$BREW_PREFIX/opt/curl/bin:$PATH"
fi

# export LDFLAGS="-shared -L$OPENSSL_HOME/lib -L${BREW_PREFIX}/lib"
# export LDFLAGS="-L$OPENSSL_HOME/lib"
# export CPPFLAGS="-I$OPENSSL_HOME/include -I$(xcrun --show-sdk-path)/usr/include/sasl -I${BREW_PREFIX}/include"
# export PKG_CONFIG_PATH="$OPENSSL_HOME/lib/pkgconfig"
# export LDFLAGS=
# export CPPFLAGS=-I/usr/local/opt/readline/include

# NOTE: horrible openssl osx hacks :(
[[ -L ${BREW_PREFIX}/lib/libcrypto.1.0.0.dylib ]] || ln -s $OPENSSL_HOME/lib/libcrypto.1.0.0.dylib ${BREW_PREFIX}/lib/
[[ -L ${BREW_PREFIX}/lib/libssl.1.0.0.dylib ]] || ln -s $OPENSSL_HOME/lib/libssl.1.0.0.dylib ${BREW_PREFIX}/lib/

# NOTE: required to compile rust-openssl
export OPENSSL_INCLUDE_DIR="$OPENSSL_HOME/include"
export DEP_OPENSSL_INCLUDE="$OPENSSL_HOME/include"

# ZEPPELIN SPECIFIC
if [[ -d $HOME/.zeppelin-conf ]]; then
    export ZEPPELIN_CONF_DIR="$HOME/.zeppelin-conf"
fi

# nodejs specific
export BREW_NVM_HOME="${BREW_PREFIX}/opt/nvm"
if [[ -d $BREW_NVM_HOME ]]; then
    export NVM_DIR="$HOME/.nvm"
    [[ -d "$NVM_DIR" ]] || mkdir -p "$NVM_DIR"
    source "$BREW_NVM_HOME/nvm.sh"
fi


function vimeo-dl {
  youtube-dl $@
}

function http-python2 {
    PORT=${1-8000}
    echo "serving http-python2"
    HTTP_SERVER_PY=$(cat <<EOF
import SimpleHTTPServer
import SocketServer
PORT = $PORT
class Handler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    pass
Handler.extensions_map['.md'] = 'text/markdown'
httpd = SocketServer.TCPServer(("", PORT), Handler)
print "serving at port", PORT
try:
    httpd.serve_forever()
except:
    httpd.shutdown()
    pass
EOF
)
    open http://localhost:$PORT
    python -c "$HTTP_SERVER_PY"
}

function http-python3 {
    PORT=${1-8000}
    echo "serving http-python3"
    HTTP_SERVER_PY=$(cat <<EOF
import http.server
from http.server import HTTPServer, BaseHTTPRequestHandler
import socketserver
PORT = $PORT
Handler = http.server.SimpleHTTPRequestHandler
Handler.extensions_map['.md'] = 'text/markdown'
httpd = socketserver.TCPServer(("", PORT), Handler)
print("serving at port", PORT)
try:
    httpd.serve_forever()
except:
    httpd.shutdown()
    pass
EOF
)
    open http://localhost:$PORT
    python -c "$HTTP_SERVER_PY"
}

function http-python {
    HTTP_PORT=${1-8000}
    PY_VERSION="$(python -V 2>&1 | cut -d' ' -f2)"
    case "${PY_VERSION%%.*}" in
        2) http-python2 "$HTTP_PORT" ;;
        3) http-python3 "$HTTP_PORT" ;;
        *) echo-err "unexpected python version $PY_VERSION"; return 1 ;;
    esac
}

alias "ip-addr"="ipconfig getifaddr en0"
alias "docker-rm-dangling"='docker rmi -f $(docker images -q --filter "dangling=true")'
alias "certs-show-csr"='openssl req -noout -text -in '
alias "certs-show-key"='openssl rsa -noout -text -in '
alias "certs-show-pem"='openssl x509 -noout -text -in '
alias "certs-show-sig"='openssl pkcs7 -inform der -noout -text -print_certs -in '
alias urldecode='python -c "import sys; from urllib.parse import unquote_plus; print(unquote_plus(sys.argv[1]))"'
alias urlencode='python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.argv[1]))"'
alias stripcolors='gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'

alias ic='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

if [[ -f $HOME/.secrets/exports ]]; then
    source $HOME/.secrets/exports
fi

# ruby rbenv specific
if type -p rbenv > /dev/null 2>&1; then
    export PATH="${BREW_PREFIX}/opt/rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# python pyenv specific
if type -p pyenv > /dev/null 2>&1; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    eval "$(pyenv init -)"
    type -p pyenv-virtualenv-init > /dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"
fi
