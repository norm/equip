#!/usr/bin/env bash

yellow=$'\e'[33m
reset=$'\e'[0m
TEMP_CRON=$( mktemp '/tmp/crontab.original.XXXXX' )

@test cron_entry {
    skip "Triggers a security prompt, run manually"

    if crontab -l > $TEMP_CRON; then
        crontab /dev/null
    fi

    run ./kitout.sh tests/cron.kitfile
    echo "$output"

    [ $status -eq 0 ]
    [ "${lines[0]}" == "${yellow}=== added '*     *     *     *     *     sleep 1' to crontab${reset}" ]

    if [ "$(stat -f'%z' $TEMP_CRON)" -gt 0 ]; then
        crontab $TEMP_CRON
    else
        crontab /dev/null
    fi
}
