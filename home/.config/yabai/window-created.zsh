#! /usr/bin/zsh

is_app() {
    echo $(yabai -m query --spaces --space \
        | jq -re ".index" \
        | xargs -I{} yabai -m query --windows --space {} \
        | jq -r 'map(select(.id=='$YABAI_WINDOW_ID' and .app=="'$1'" and .subrole=="AXStandardWindow")) | .[] | [.app][]')
}

if [[ $(is_app "Finder") == "Finder" ]]; then
    yabai -m window --focus $YABAI_WINDOW_ID \
        & yabai -m window --move abs:0:709 \
        & yabai -m window --resize abs:1500:730
fi
