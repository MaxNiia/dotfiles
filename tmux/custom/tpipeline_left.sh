show_tpipeline_left() { # save this module in a file with the name tpipeline_left.sh
  local index=$1 # this variable is used by the module loader in order to know the position of this module
  local icon="$(get_tmux_option "@catppuccin_tpipeline_left_icon" "")"
  local color="$(get_tmux_option "@catppuccin_tpipeline_left_color" "$thm_green")"
  local text="$(get_tmux_option "@catppuccin_tpipeline_left_text" '#(cat #{socket_path}-\#{session_id}-vimbridge)')"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
