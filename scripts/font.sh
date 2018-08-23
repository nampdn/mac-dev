#!/bin/bash

# Copy all saved font from user_config directory.
copy_fonts() {
  local user_font_dir="$1"
  if [ -d $user_font_dir ]; then
    cp -R "$user_font_dir" "$HOME/Library/Fonts"
    fancy_echo "Copied all fonts in $user_font_dir to Font Book!"
  fi
}
