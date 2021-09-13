#!/usr/bin/env bash

@test cron_entry {
    ! color_meter_is_running

    run ./kitout.sh tests/start.kitfile

    [ $status -eq 0 ]
    color_meter_is_running
}

function color_meter_is_running {
    ps x | grep '[/]Digital Color Meter.app/'
}

function setup_file {
    teardown
}

function teardown {
    pid=$(color_meter_is_running | cut -d' ' -f1 )
    [ -n "$pid" ] && kill $pid || true
}
