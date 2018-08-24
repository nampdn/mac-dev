#!/bin/bash

# Installing the Xcode command line tools on 10.7.x or higher

osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# Installing the latest Xcode command line tools on 10.9.x or higher

if [[ "$osx_vers" -ge 9 ]]; then

	# Create the placeholder file which is checked by the softwareupdate tool 
	# before allowing the installation of the Xcode command line tools.
	
	touch "$cmd_line_tools_temp_file"
	
	# Identify the correct update in the Software Update feed with "Command Line Tools" in the name for the OS version in question.
	
	if [[ "$osx_vers" -gt 9 ]]; then
	   cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "$osx_vers" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	elif [[ "$osx_vers" -eq 9 ]]; then
	   cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "Mavericks" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	fi
	
	# Check to see if the softwareupdate tool has returned more than one Xcode
	# command line tool installation option. If it has, use the last one listed
	# as that should be the latest Xcode command line tool installer.
	
	if (( $(grep -c . <<<"$cmd_line_tools") > 1 )); then
	   cmd_line_tools_output="$cmd_line_tools"
	   cmd_line_tools=$(printf "$cmd_line_tools_output" | tail -1)
	fi
	
	#Install the command line tools
  local installed_marker="$DEVFOR_ROOT/.clt"
	if [ ! -f $installed_marker ]; then
	  softwareupdate -i "$cmd_line_tools" --verbose
    echo $cmd_line_tools > $installed_marker
	else
    echo "Skipping Command Line Tools install..."
  fi
  
	# Remove the temp file
	
	if [[ -f "$cmd_line_tools_temp_file" ]]; then
	  rm "$cmd_line_tools_temp_file"
	fi
fi
