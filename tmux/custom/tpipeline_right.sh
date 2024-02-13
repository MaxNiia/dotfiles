show_tpipeline_right() { # save this module in a file with the name tpipeline_right.sh
  local index=$1 # this variable is used by the module loader in order to know the position of this module
  local icon="$(get_tmux_option "@catppuccin_tpipeline_right_icon" "")"
  local color="$(get_tmux_option "@catppuccin_tpipeline_right_color" "$thm_green")"
  local text="$(get_tmux_option "@catppuccin_tpipeline_right_text" '#(cat #{socket_path}-\#{session_id}-vimbridge-R)')"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
