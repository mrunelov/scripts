#!/bin/bash

#
# A script that automatically creates playlists for VLC.
#
# Usage:
#
# pl <name-pattern> <season> <from> <to>
#
# The last or last three parameters are optional.
#
# Sample usage:
#
# pl thrones (Creates a playlist with the first 5 matches)
#
# pl "west\ wing" 3 12 (Opens West Wing season 3 episode 12)
#
# pl firefly 1 1 12 (Creates a playlist with Firefly episodes 1-12)
#
#
# Defaults to $HOME/Downloads if season number is omitted. Otherwise, $HOME is
# searched.
#
# Notes:
#
# # The pattern matching requires the season folder to contain the show's name.
# The last item of the playlist is initially played when running on Mac OS X.
# The playlist is added twice on Mac OS X.

# Fetch parameters and store them in variables
show=$1
season=$2
from=$3

# Initialize pattern expression used by find
find_pattern="'*$1*$2*'"

single_file_pattern="*$show*"
vlc_argument=""

# Check if season was submitted.
# If not, Downloads will be searched for a matching file,
# playing the earliest if multiple exist (using sort)
if [ -z "$2" ] ;
then
	folder="\"$HOME/Downloads/\""
	IFS=$'\n'
	argument_array=($(find "$HOME" -iname "$single_file_pattern.avi" -o -iname "$single_file_pattern.mp4" -o -iname "$single_file_pattern.mpg" -o -iname "$single_file_pattern.mkv" -type f 2>/dev/null | sort -d | head -5))
	# Testing length of vlc_argument since it will have two whitespaces in it if "find" fails,
	# So null or empty-string checks does not work.
	if [ "${#argument_array[@]}" -eq 0 ] ; 
	then
		echo "No match found."
	else
		for (( j=0; j<${#argument_array[@]}; j++));
		do
			vlc_argument="$vlc_argument \"${argument_array[$j]}\""
		done
		# Append string to prevent stdout and stderr 
		vlc_argument="$vlc_argument > /dev/null 2> /dev/null &"
		eval /Applications/VLC.app/Contents/MacOS/VLC "$vlc_argument"
	fi

else
	# Check if multiple videos are to be added
	if [ -z "$4" ] ; 

	then
		to=$3
	else 
		to=$4
	fi

	# Find correct folder using pattern on show name
	findfolder=$(eval "find "$HOME" -iname "$find_pattern" -type d -print 2>/dev/null | sort -d | head -1" )
	folder="\"$findfolder/\""
	# Check if folder was found
	if [ "$folder" = "\"/\"" ] ;
	then
		folder="\"$HOME/Downloads/\""
		findfolder="$HOME/Downloads"
		season_name_pattern="$1"
	fi
	
		# Loop to create vlc_argument for multiple files
		for (( i = $from; i<= $to; i++ ))

		do
			if [ "$i" -lt 10 ];
			then temp_pattern="*$2*0$i*"
			temp=$(eval echo "$folder$season_name_pattern$temp_pattern")
			else temp=$(eval echo "$folder$season_name_pattern*$2*$i*")
			fi
			if [ "$temp" = "$findfolder/$season_name_pattern$temp_pattern" ] || [ "$temp" = "$findfolder/$season_name_pattern*$2*$i*" ] ;
			then 
				echo "Episode $i not found."
			else
				vlc_argument="$vlc_argument \"$temp\""
			fi

		done
		if [ -z "$vlc_argument" ] ;
		then
			echo "No episodes found."
		else
			# Append string to prevent stdout and stderr 
			vlc_argument="$vlc_argument > /dev/null 2> /dev/null &"
            # VLC Command for Mac OS X
            eval /Applications/VLC.app/Contents/MacOS/VLC "$vlc_argument"
            # VLC Command for GNU/Linux
            # vlc vlc_argument &
		fi
fi


