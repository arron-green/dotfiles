VUNDLE_HOME=~/.vim/bundle/Vundle.vim
DEV_HOME=~/dev

function exists-in-path {
    ARG=$1
    if [[ ! -z $ARG ]]; then
        type -p $ARG > /dev/null 2>&1
        return $?
    fi
    return 1
}

[ -d $DEV_HOME ] || mkdir -p $DEV_HOME

# install home brew if not installed
exists-in-path brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
cd brew && brew bundle

# link vimrc
if [[ ! -L ~/.vimrc ]]; then
  ln -s $PWD/vimrc ~/.vimrc
fi

# download vundle
if [[ ! -e $VUNDLE_HOME ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_HOME
fi

# install vundle plugins
vim +PluginInstall +qall

# setup python environment
exists-in-path pip && exists-in-path virtualenvwrapper.sh || pip install virtualenvwrapper

# link profile
if [[ ! -L ~/.profile ]]; then
  ln -s $PWD/profile.sh ~/.profile
fi

# create local .bin dir
[ -d ~/.bin ] || mkdir ~/.bin

# create virtualenvs directory
[ -d ~/.virtualenvs ] || mkdir ~/.virtualenvs

# link git info
if [[ ! -L ~/.gitconfig ]]; then
    # rm if exists but is not a symlink
    [[ -e ~/.gitconfig ]] && rm ~/.gitconfig
    # link to dotfiles gitconfig
    ln -s $PWD/gitconfig ~/.gitconfig
fi

