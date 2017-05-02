VUNDLE_HOME=~/.vim/bundle/Vundle.vim
DEV_HOME=~/dev
REPO_PATH=$(git rev-parse --show-toplevel)

function exists-in-path {
    if [[ ! -z $1 ]]; then
        type -p $1 > /dev/null 2>&1
        return $?
    else
        return 1
    fi
}

[ -d $DEV_HOME ] || mkdir -p $DEV_HOME

# install home brew if not installed
exists-in-path brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
cd brew && brew bundle

# link vimrc
[[ -L ~/.vimrc && "$REPO_PATH/vimrc" == "$(readlink ~/.vimrc)" ]] || ([[ -e ~/.vimrc ]] && rm ~/.vimrc)
[[ -L ~/.vimrc ]] || ln -s $REPO_PATH/vimrc ~/.vimrc

# download vundle
if [[ ! -e $VUNDLE_HOME ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_HOME
fi

# install vundle plugins
vim +PluginInstall +qall

# setup python environment
exists-in-path pip && exists-in-path virtualenvwrapper.sh || pip install virtualenvwrapper

# create local .bin dir
[ -d ~/.bin ] || mkdir ~/.bin

# create virtualenvs directory
[ -d ~/.virtualenvs ] || mkdir ~/.virtualenvs

# link bash profile
[[ -L ~/.profile && "$REPO_PATH/profile.sh" == "$(readlink ~/.profile)" ]] || ([[ -e ~/.profile ]] && rm ~/.profile)
[[ -L ~/.profile ]] || ln -s $REPO_PATH/profile.sh ~/.profile

# link gitconfig
[[ -L ~/.gitconfig && "$REPO_PATH/gitconfig" == "$(readlink ~/.gitconfig)" ]] || ([[ -e ~/.gitconfig ]] && rm ~/.gitconfig)
[[ -L ~/.gitconfig ]] || ln -s $REPO_PATH/gitconfig ~/.gitconfig

# link global gitignore
[[ -L ~/.gitignore && "$REPO_PATH/gitignore" == "$(readlink ~/.gitignore)" ]] || ([[ -e ~/.gitignore ]] && rm ~/.gitignore)
[[ -L ~/.gitignore ]] || ln -s $REPO_PATH/gitignore ~/.gitignore

