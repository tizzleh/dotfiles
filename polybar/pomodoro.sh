#!/bin/bash

# Constants
FOCUS_TIME=$((25*60))  # 25 minutes
SHORT_BREAK=$((5*60))  # 5 minutes
LONG_BREAK=$((15*60))  # 15 minutes
TIMER_FILE="/tmp/polybar_timer"
CONTROL_FILE="/tmp/polybar_timer_control"

# State: 0 = focus, 1 = short break, 2 = long break
state=0
start_time=$(date +%s)
end_time=$(($start_time + $FOCUS_TIME))

while true; do
    now=$(date +%s)
    if (( $now >= $end_time )); then
        case $state in
            0)
                # Switch to short break after focus
                state=1
                end_time=$(($now + $SHORT_BREAK))
                ;;
            1)
                # Switch to long break after short break
                state=2
                end_time=$(($now + $LONG_BREAK))
                ;;
            2)
                # Switch back to focus after long break
                state=0
                end_time=$(($now + $FOCUS_TIME))
                ;;
        esac
    fi
    
    if [ -f $CONTROL_FILE ]; then
        control_command=$(cat $CONTROL_FILE)
        rm $CONTROL_FILE
        case $control_command in
            'focus')
                state=0
                end_time=$(($now + $FOCUS_TIME))
                ;;
            'short_break')
                state=1
                end_time=$(($now + $SHORT_BREAK))
                ;;
            'long_break')
                state=2
                end_time=$(($now + $LONG_BREAK))
                ;;
        esac
    fi

    remaining=$(( $end_time - $now ))
    min=$(( $remaining / 60 ))
    sec=$(( $remaining % 60 ))
    case $state in
        0) prefix="Focus: ";;
        1) prefix="Short Break: ";;
        2) prefix="Long Break: ";;
    esac
    echo "$prefix$min minutes, $sec seconds remaining" > $TIMER_FILE
    sleep 1
done

