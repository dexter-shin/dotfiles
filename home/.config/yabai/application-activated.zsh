#! /usr/bin/zsh

# When there are more than 3 windows open on the current space we stack Google
# Chrome and Transmit along with stacking VSCode and Tower if both are open.

# Get all the windows on current space
local WINDOWS_ARRAY=$(yabai -m query --spaces --space \
  | jq -re ".index" \
  | xargs -I{} yabai -m query --windows --space {} \
  | jq -r 'map(select(.minimized==0 and .floating==0))')

# Get the number of windows on the current space
local NUMBER_OF_WINDOWS=$(echo $WINDOWS_ARRAY | jq -r 'length')

# If we are Less than or equal to 3 windows on current space exit script
if [ "$NUMBER_OF_WINDOWS" -le "3" ]; then
    return 42
fi

# Stack first instance of VSCode and Tower when more than 3 windows
local VSCODE_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Code")) | .[0] | .id')
local TOWER_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Tower")) | .[0] | .id')

if [[ $VSCODE_ID != 'null' && $TOWER_ID != 'null' ]]; then;
    yabai -m window $VSCODE_ID --stack $TOWER_ID
fi

# Stack first instance of Google Chrome and Transmit when more than 3 windows
local CHROME_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Google Chrome")) | .[0] | .id')
local TRANSMIT_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Transmit")) | .[0] | .id')

if [[ $CHROME_ID != 'null' && $TRANSMIT_ID != 'null' ]]; then;
    yabai -m window $CHROME_ID --stack $TRANSMIT_ID
fi
