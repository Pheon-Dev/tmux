VAR_KEY_PREFIX="@sidebar-key"
REGISTERED_PANE_PREFIX="@-sidebar-registered-pane"
REGISTERED_SIDEBAR_PREFIX="@-sidebar-is-sidebar"
MINIMUM_WIDTH_FOR_SIDEBAR="71"

TREE_KEY="Tab"
TREE_OPTION="@sidebar-tree"

TREE_FOCUS_KEY="a"
TREE_FOCUS_OPTION="@sidebar-tree-focus"

TREE_COMMAND="fd . | xargs exa --icons -T --color=always --group-directories-first && fzf-tmux -d | xargs bat -p --color=always"
TREE_COMMAND_OPTION="@sidebar-tree-command"

# TREE_PAGER='sh -c "LESS= less --dumb --chop-long-lines --tilde --IGNORE-CASE --RAW-CONTROL-CHARS"'
TREE_PAGER='sh -c "bat --color=always --style=numbers --line-range=:500"'
TREE_PAGER_OPTION="@sidebar-tree-pager"

TREE_POSITION="left"
TREE_POSITION_OPTION="@sidebar-tree-position"

# TREE_WIDTH="50"
TREE_WIDTH_OPTION="@sidebar-tree-width"

SUPPORTED_TMUX_VERSION="1.9"

SIDEBAR_DIR="$HOME/.tmux/sidebar"