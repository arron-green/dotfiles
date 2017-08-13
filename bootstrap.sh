export DEV_HOME=${HOME}/dev
export REPO_PATH=$(git rev-parse --show-toplevel)
VIMPLUG_HOME=${HOME}/.vim/autoload

function exists-in-path {
    if [[ ! -z $1 ]]; then
        type -p $1 > /dev/null 2>&1
        return $?
    else
        return 1
    fi
}

[ -d $DEV_HOME ] || mkdir -p $DEV_HOME

xcode-select -p || {
    echo "xcodebuild accept license"; \
    sudo xcodebuild -license accept; \
    xcode-select --install;
}

# bootstrap homebrew
exists-in-path brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install homebrew deps
brew bundle --file=${REPO_PATH}/brew/Brewfile

# link vimrc
[[ -L ~/.vimrc && "$REPO_PATH/vimrc" == "$(readlink ~/.vimrc)" ]] || ([[ -e ~/.vimrc ]] && rm ~/.vimrc)
[[ -L ~/.vimrc ]] || ln -s $REPO_PATH/vimrc ~/.vimrc

# link bash profile
[[ -L ~/.profile && "$REPO_PATH/profile.sh" == "$(readlink ~/.profile)" ]] || ([[ -e ~/.profile ]] && rm ~/.profile)
[[ -L ~/.profile ]] || ln -s $REPO_PATH/profile.sh ~/.profile

# link gitconfig
[[ -L ~/.gitconfig && "$REPO_PATH/gitconfig" == "$(readlink ~/.gitconfig)" ]] || ([[ -e ~/.gitconfig ]] && rm ~/.gitconfig)
[[ -L ~/.gitconfig ]] || ln -s $REPO_PATH/gitconfig ~/.gitconfig

# link global gitignore
[[ -L ~/.gitignore && "$REPO_PATH/gitignore" == "$(readlink ~/.gitignore)" ]] || ([[ -e ~/.gitignore ]] && rm ~/.gitignore)
[[ -L ~/.gitignore ]] || ln -s $REPO_PATH/gitignore ~/.gitignore

# create local .bin dir
[ -d ~/.bin ] || mkdir ~/.bin

# setup python environment
./pyenv-versions.sh

# setup vim-plug
[ -d $VIMPLUG_HOME ] || mkdir -p $VIMPLUG_HOME
[ -f $VIMPLUG_HOME/plug.vim ] || curl -Lo $VIMPLUG_HOME/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# ensure vim plugin deps are installed
vim +PlugInstall +qall

# install extra tools not available via brew
./tools.sh

