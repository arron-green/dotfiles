export BASH_SILENCE_DEPRECATION_WARNING=1

# adds color to my terminal
export TERM="xterm-256color"
export COLORTERM="truecolor"
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'
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
EDITOR="$(command -v vim)"
export EDITOR

if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
if [[ -d /opt/homebrew/sbin ]]; then
    export PATH="/opt/homebrew/sbin:$PATH"
fi

function echo-err() {
    printf "%s\n" "$*" >&2;
}
export -f echo-err

# function ps1-prompt() {
#     # current working directory
#     PS1_PREFIX="${COLOR_GREEN}\W${COLOR_NIL}"
#
#     # git info
#     export GIT_PS1_SHOWCOLORHINTS=true
#     GIT_PS=$(__git_ps1 "%s")
#     if [[ ! -z $GIT_PS ]]; then
#       if [ "$(is-git-dirty)" == "1" ]; then
#           GIT=" (${COLOR_RED}${GIT_PS}${COLOR_NIL})"
#       else
#           GIT=" (${GIT_PS})"
#       fi
#     else
#       GIT=""
#     fi
#
#     # python specific
#     VENV=""
#     if [[ -n $VIRTUAL_ENV ]]; then
#         VENV=" [${COLOR_BLUE}${PYENV_VERSION-V}${COLOR_NIL}]"
#     fi
#
#     END="${COLOR_GREEN}\$${COLOR_NIL} "
#     export PS1="${PS1_PREFIX}${VENV}${GIT} ${END}"
# }
#export -f ps1-prompt
#export PROMPT_COMMAND=ps1-prompt
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
  local source
  source="$(type -p scala)"
  while [ -h "$source" ] ; do
    local linked
    linked="$(readlink "$source")"
    local dir
    dir="$( cd -P "$(dirname "$source")" && cd -P "$(dirname "$linked")" && pwd )"
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
    BN=$(git-branch)
    if [ "$?" == "0" ]; then
        echo "$BN" | tr -d '\n' | pbcopy
    fi
}

function pip-remove-globals {
    while read -r P; do
        pip uninstall -y "${P}";
    done < <(pip list --format=json | jq -rc '.[] .name' | egrep -v 'pip|setuptools|wheel|six')
}

function notify {
  start=$(date +%s)
  $*
  end=$(date +%s)
  terminal-notifier -message "$*" -title done -subtitle "$(($end - $start)) seconds"
}

function kube-dashboard {
    kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml"
}

# Docker specific
function docker-image-grep {
  QUIET=false
  IMAGE=()
  while [[ $# -gt 0 ]] && [[ ."$1" = .--* ]] ;do
      opt="$1"; shift;
      case "$opt" in
          "--" ) break 2;;
          "-q" | "--quiet" )
              QUIET=true
              ;;
          -*)
              echo >&2 "Invalid option: $*";
              return 1;;
          *)
              IMAGE+=("${1}");
              shift;
              ;;
      esac
  done
  IMAGE=$( IFS=$'|'; echo "${IMAGE[*]}" )

  JSON=$(docker images --format '{{json .}}' | jq --arg IMAGE $IMAGE -rc 'select(.Repository | test($IMAGE))')
  if [[ "$?" == "0" ]]; then
      if [[ "$QUIET" == "true" ]]; then
          echo $JSON | jq -rc '.ID' | xargs
      else
          echo $JSON | jq -rc .
      fi
  fi
}

function docker-ps-image {
    IMAGE=$1
    [[ -z "${IMAGE}" ]] || docker ps --filter=ancestor=$@
}

function epoch-to-human {
  EPOCH="$1"
  if [ ! -z $EPOCH ]; then
      gdate -d @$EPOCH +'%F %r %Z'
  fi
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


function ack-json-log {
    ack '^<\d+>\d+-\d+-\d+T\d+:\d+:\d+Z\s[\w-]+\s[\w\(\)\[\]-]+:\s(?<json>\{.+\})$' --output '$+{json}' $@
}


GRAAL_BUILD="20.3.1"
# GRAALVM_VERSION="java8-${GRAAL_BUILD}"
GRAALVM_VERSION="java11-${GRAAL_BUILD}"
GRAALVM_HOME="/Library/Java/JavaVirtualMachines/graalvm-ce-lts-${GRAALVM_VERSION}"
# On macOS Catalina, you may get a warning that "the developer cannot be
# verified". This check can be disabled in the "Security & Privacy"
# preferences pane or by running the following command:
# xattr -r -d com.apple.quarantine ${GRAALVM_HOME}

# export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
if [[ -e "${GRAALVM_HOME}/Contents/Home" ]]; then
    export JAVA_HOME="${GRAALVM_HOME}/Contents/Home"
    # export PATH="${JAVA_HOME}/bin:${PATH}"
fi

export GRADLE_HOME="${BREW_PREFIX}/opt/gradle"

export SBT_OPTS="-XX:MaxMetaspaceSize=512m -Xms512M -Xmx6096M -Xss12M"
# default to scala 2.11
BREW_SCALA_HOME="${BREW_PREFIX}/opt/scala@2.12"
if [[ -d "${BREW_SCALA_HOME}/bin" ]]; then
    export PATH="${BREW_SCALA_HOME}/bin:$PATH"
    export SCALA_HOME="$(find-scala-home)"
fi

export HOME_BIN="${HOME}/.bin"
export PATH="${HOME_BIN}:/usr/local/sbin:$PATH"

export LOCAL_BIN_HOME="${HOME}/.local/bin"
if [[ -d ${LOCAL_BIN_HOME} ]]; then
    export PATH="$PATH:${LOCAL_BIN_HOME}"
fi

if [[ -d $HOME/.conscript ]]; then
    export CONSCRIPT_HOME="$HOME/.conscript"
    export PATH="$PATH:$HOME/.conscript/bin"
fi

export OPENSSL_HOME="${BREW_PREFIX}/opt/openssl"
export PATH="$OPENSSL_HOME/bin:$PATH"


# export CONFLUENT_VERSION="5.5.0"
export CONFLUENT_VERSION="7.0.0"
export CONFLUENT_SCALA_VERSION="2.12"
export CONFLUENT_HOME="/usr/local/confluent-${CONFLUENT_VERSION}"
if [[ -d ${CONFLUENT_HOME}/bin ]]; then
    export PATH="$PATH:${CONFLUENT_HOME}/bin"
fi

function confluent-install {
    #CONFLUENT_ZIP="confluent-${CONFLUENT_VERSION}-${CONFLUENT_SCALA_VERSION}.zip"
    CONFLUENT_ZIP="confluent-community-${CONFLUENT_VERSION}.zip"
    CONFLUENT_TMP="/tmp/${CONFLUENT_ZIP}"
    CONFLUENT_DL="https://packages.confluent.io/archive/${CONFLUENT_VERSION%.*}/${CONFLUENT_ZIP}"
    echo "${CONFLUENT_DL}"
    curl -L -o "${CONFLUENT_TMP}" -C - "${CONFLUENT_DL}" \
        && unzip "${CONFLUENT_TMP}" -d /tmp \
        && sudo mv "/tmp/confluent-${CONFLUENT_VERSION}" "/usr/local/"
    }

function confluent-cli-install {
    CLI_FILE="confluent_latest_darwin_amd64.tar.gz"
    CLI_DL_FILE="/tmp/${CLI_FILE}"
    CLI_URL="https://s3-us-west-2.amazonaws.com/confluent.cloud/confluent-cli/archives/latest/${CLI_FILE}"
    curl --silent -L -o ${CLI_DL_FILE} -C - ${CLI_URL}
    tar -C /tmp -xvf ${CLI_DL_FILE}
    cp /tmp/confluent/confluent ${HOME_BIN}
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
            --config cleanup.policy=compact \
            --config min.cleanable.dirty.ratio=0.01 \
            --config segment.ms=100 \
            --config delete.retention.ms=100
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

function coursier-update {
    [[ -d "${HOME_BIN}" ]] || mkdir -p "${HOME_BIN}"
    curl --silent --fail -Lo ${HOME_BIN}/cs "https://git.io/coursier-cli-macos" \
        && chmod +x ${HOME_BIN}/cs \
        && (xattr -d com.apple.quarantine ${HOME_BIN}/cs || true) \
        && ${HOME_BIN}/cs
}

function password-env {
    local ENV_VAR="${1}"
    if [[ -n "${ENV_VAR}" ]]; then
        echo -n "Assign password to ${ENV_VAR}: "
        stty -echo
        read ${ENV_VAR}
        stty echo
        echo
    else
        echo-err "Usage: ${0} [env-var]"
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
export LDFLAGS="-L${BREW_PREFIX}/opt/zlib/lib -L${BREW_PREFIX}/opt/sqlite/lib"
export CPPFLAGS="-I${BREW_PREFIX}/opt/zlib/include -I${BREW_PREFIX}/opt/sqlite/include"

# NOTE: horrible openssl osx hacks :(
[[ -L ${BREW_PREFIX}/lib/libcrypto.1.0.0.dylib ]] || ln -s $OPENSSL_HOME/lib/libcrypto.1.0.0.dylib ${BREW_PREFIX}/lib/
[[ -L ${BREW_PREFIX}/lib/libssl.1.0.0.dylib ]] || ln -s $OPENSSL_HOME/lib/libssl.1.0.0.dylib ${BREW_PREFIX}/lib/

# NOTE: required to compile rust-openssl
export OPENSSL_INCLUDE_DIR="$OPENSSL_HOME/include"
export DEP_OPENSSL_INCLUDE="$OPENSSL_HOME/include"

# RUST SPECIFIC
if [[ -d ${HOME}/.cargo/bin ]]; then
    export PATH="${HOME}/.cargo/bin:$PATH"
fi

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

function kafka-topic-size {
	local BOOTSTRAP_SERVERS="${1}"
	local TOPIC="${2}"
    OUTPUT="$(kafka-log-dirs \
            --bootstrap-server "${BOOTSTRAP_SERVERS}" \
            --topic-list "${TOPIC}" \
            --describe | grep -E '^{' \
            | jq -rc \
                --arg TOPIC "${TOPIC}" \
                '{topic: $TOPIC, size: ([ ..|.size? | numbers ] | add)}')"
    SIZE="$(jq -rc '.size'<<<"${OUTPUT}")"
    HR="$(numfmt --to=iec<<<"${SIZE}")"
    RESULT="$(jq -rc --arg HR "${HR}" '.+={hr: $HR}'<<<"${OUTPUT}")"
    echo-err "${RESULT}"
    echo "${RESULT}"
}
export -f kafka-topic-size

function kafka-topics-report {
	local BOOTSTRAP_SERVERS="${1}"
	if [[ -z "${BOOTSTRAP_SERVERS}" ]]; then
		echo-err "usage: $0 [bootstrap-server]"
	else
        REPORT="$(mktemp -t kafka-topics-report)"
        kafka-topics \
            --bootstrap-server "${BOOTSTRAP_SERVERS}" \
            --list \
            | xargs -n 1 -P8 -I {} bash -c "$(printf 'kafka-topic-size "%s" $@' "${BOOTSTRAP_SERVERS}")" _ {} > "${REPORT}"
        jq --slurp -rc 'sort_by(.size * -1) | .[]' "${REPORT}"
    fi
}

alias 'port-check'='nc -vnzu '
alias 'port-check-local'='nc -vnzu 127.0.0.1'
alias "kctl"="kubectl"
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

# 1password cli access
function 1password-cli {
    if [[ -f $HOME/.oprc ]]; then
        source $HOME/.oprc
    fi
}

if [[ -f $HOME/.secrets/exports ]]; then
    source $HOME/.secrets/exports
fi

if [[ -d ${BREW_PREFIX}/opt/mysql-client/bin ]]; then
    export PATH="${BREW_PREFIX}/opt/mysql-client/bin:$PATH"
fi

# ruby rbenv specific
# if type -p rbenv > /dev/null 2>&1; then
#     export PATH="${BREW_PREFIX}/opt/rbenv/bin:$PATH"
#     eval "$(rbenv init -)"
# fi

# python pyenv specific
if type -p pyenv > /dev/null 2>&1; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    eval "$(pyenv init -)"
    type -p pyenv-virtualenv-init > /dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"
fi

# direnv
eval "$(direnv hook bash)"

ulimit -S -n 2049
export GOPATH=~/dev/go
