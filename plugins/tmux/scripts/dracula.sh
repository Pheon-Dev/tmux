#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
# ~/.tmux.conf
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh

main() {
    datafile=/tmp/.dracula-tmux-data

    # set configuration option variables
    show_fahrenheit=$(get_tmux_option "@dracula-show-fahrenheit" true)
    show_location=$(get_tmux_option "@dracula-show-location" true)
    fixed_location=$(get_tmux_option "@dracula-fixed-location")
    show_powerline=$(get_tmux_option "@dracula-show-powerline" false)
    show_flags=$(get_tmux_option "@dracula-show-flags" false)
    show_left_icon=$(get_tmux_option "@dracula-show-left-icon" smiley)
    show_left_icon_padding=$(get_tmux_option "@dracula-left-icon-padding" 1)
    show_military=$(get_tmux_option "@dracula-military-time" false)
    show_timezone=$(get_tmux_option "@dracula-show-timezone" true)
    show_left_sep=$(get_tmux_option "@dracula-show-left-sep" ⦚)
    show_right_sep=$(get_tmux_option "@dracula-show-right-sep" ⦚)
    show_border_contrast=$(get_tmux_option "@dracula-border-contrast" false)
    show_day_month=$(get_tmux_option "@dracula-day-month" false)
    show_refresh=$(get_tmux_option "@dracula-refresh-rate" 5)
    IFS=' ' read -r -a plugins <<<$(get_tmux_option "@dracula-plugins" "battery network weather")

    # Dracula Color Pallette
    black='#21222c'
    black_one='#21222c'
    dark_gray='#21222c'
    grey_three='#282a36'
    grey_one='#4e4e4e'
    gray='#44475a'
    t_fg_gutter='#505050'
    grey_two='#666666'
    grey='#7f7f7f'
    t_blue7='#394b70'
    t_dark3='#545c7e'
    t_blue0='#3d59a1'
    dark_purple='#6272a4'
    light_purple='#bd93f9'
    t_magenta='#bb9af7'
    t_purple1='#8d7cd8'
    t_purple2='#c66bfe'
    t_purple='#c678dd'
    pink='#ff79c6'
    red='#f7101b'
    t_magenta2='#ff007c'
    t_dark5='#737aa2'
    t_fg_dark='#a9b1d6'
    white='#f8f8f2'
    t_fg='#c0caf5'
    t_blue8='#7aa2f7'
    t_cyan1='#7dcfff'
    t_blue5='#89ddff'
    t_blue6='#B4F9F8'
    t_comment='#7aa2f7'
    cyan='#8be9fd'
    t_green0='#73daca'
    t_green1='#00aaef'
    t_cyan='#10f0e0'
    t_blue1='#2ac3de'
    t_green2='#30aaef'
    t_blue2='#0db9d7'
    blue='#6790eb'
    t_blue='#1098f8'
    t_teal='#1abc9c'
    t_green3='#41a6b5'
    t_green='#9ece6a'
    green='#62ff00'
    yellow='#ffff0f'
    t_yellow1='#ffd000'
    t_orange='#ff9e64'
    t_yellow='#e0af68'
    orange='#ff7222'
    t_red='#f7768e'
    t_red1='#db4b4b'
    crimson='#67101b'

    # Handle left icon configuration☺
    case $show_left_icon in
        smiley)
            left_icon=""
            ;;
        session)
            left_icon="#S"
            ;;
        window)
            left_icon="#W"
            ;;
        *)
            left_icon=$show_left_icon
            ;;
    esac

    # Handle left icon padding
    padding=""
    if [ "$show_left_icon_padding" -gt "0" ]; then
        padding="$(printf '%*s' $show_left_icon_padding)"
    fi
    left_icon="$left_icon$padding"

    # Handle powerline option
    if $show_powerline; then
        right_sep="$show_right_sep"
        left_sep="$show_left_sep"
    fi

    # start weather script in background
    if [[ "${plugins[*]}" =~ "weather" ]]; then
        $current_dir/sleep_weather.sh $show_fahrenheit $show_location $fixed_location &
    fi

    # Set timezone unless hidden by configuration
    case $show_timezone in
        false)
            timezone=""
            ;;
        true)
            timezone="#(date +%Z)"
            ;;
    esac

    case $show_flags in
        false)
            flags=""
            current_flags=""
            ;;
        true)
            flags="#{?window_flags,#[fg=${dark_purple}]#{window_flags},}"
            current_flags="#{?window_flags,#[fg=${light_purple}]#{window_flags},}"
            ;;
    esac

    # sets refresh interval to every 5 seconds
    tmux set-option -g status-interval $show_refresh

    # set the prefix + t time format
    if $show_military; then
        tmux set-option -g clock-mode-style 24
    else
        tmux set-option -g clock-mode-style 12
    fi

    # set length
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100

    # pane border styling
    if $show_border_contrast; then
        tmux set-option -g pane-active-border-style "fg=${dark_purple}"
    else
        tmux set-option -g pane-active-border-style "fg=${light_purple}"
    fi
    tmux set-option -g pane-border-style "fg=${dark_gray}"

    # message styling
    tmux set-option -g message-style "bg=${dark_gray},fg=${white}"

    # status bar
    tmux set-option -g status-style "bg=${dark_gray},fg=${white}"

    # Status left
    tmux set-option -g status-left "#[bg=${black_one},fg=${t_purple1}]#{?client_prefix,#[fg=${t_green1}],} ${left_icon}"

    # Status right
    tmux set-option -g status-right ""

    for plugin in "${plugins[@]}"; do

        if [ $plugin = "git" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-git-colors" "dark_gray dark_purple")
            script="#($current_dir/git.sh)"
        fi

        if [ $plugin = "battery" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-battery-colors" "grey_one cyan")
            script="#($current_dir/battery.sh)"
        fi

        if [ $plugin = "gpu-usage" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-gpu-usage-colors" "pink dark_gray")
            script="#($current_dir/gpu_usage.sh)"
        fi

        if [ $plugin = "cpu-usage" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-cpu-usage-colors" "orange dark_gray")
            script="#($current_dir/cpu_info.sh)"
        fi

        if [ $plugin = "ram-usage" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-ram-usage-colors" "cyan dark_gray")
            script="#($current_dir/ram_info.sh)"
        fi

        if [ $plugin = "network" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-colors" "grey_two white")
            script="#($current_dir/network.sh)"
        fi

        if [ $plugin = "network-bandwidth" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-bandwidth-colors" "cyan dark_gray")
            tmux set-option -g status-right-length 250
            script="#($current_dir/network_bandwidth.sh)"
        fi

        if [ $plugin = "network-ping" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-ping-colors" "cyan dark_gray")
            script="#($current_dir/network_ping.sh)"
        fi

        if [ $plugin = "weather" ]; then
            # wait unit $datafile exists just to avoid errors
            # this should almost never need to wait unless something unexpected occurs
            while [ ! -f $datafile ]; do
                sleep 0.01
            done

            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-weather-colors" "orange dark_gray")
            script="#(cat $datafile)"
        fi

        if [ $plugin = "time" ]; then
            IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-time-colors" "grey_three blue")
            if $show_day_month && $show_military; then # military time and dd/mm
                script="%a %d/%m %R ${timezone}"
            elif $show_military; then # only military time
                script="%a %m/%d %R ${timezone}"
            elif $show_day_month; then # only dd/mm
                script="%a %d/%m %I:%M %p ${timezone}"
            else
                script="%a %m/%d %I:%M %p ${timezone}"
            fi
        fi

        if $show_powerline; then
            tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
            powerbg=${!colors[0]}
        else
            tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
        fi
    done

    # Window option
    tmux set-window-option -g window-status-current-format "#[fg=${t_blue8},bg=${black_one}] #I #W${current_flags} "

    tmux set-window-option -g window-status-format "#[fg=${grey}]#[bg=${black_one}] #I #W${flags}"
    tmux set-window-option -g window-status-activity-style "bold"
    tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
