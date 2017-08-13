# better xml/xpath/xslt command line tools
[ -d $DEV_HOME/saxon-lint ] || git clone https://github.com/sputnick-dev/saxon-lint.git $DEV_HOME/saxon-lint
[[ -L ~/.bin/saxon-lint && "$DEV_HOME/saxon-lint/saxon-lint.pl" == "$(readlink ~/.bin/saxon-lint)" ]] || ([[ -e ~/.bin/saxon-lint ]] && rm ~/.bin/saxon-lint)
[[ -L ~/.bin/saxon-lint ]] || ln -s $REPO_PATH/saxon-lint ~/.saxon-lint
