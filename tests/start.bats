#!/usr/bin/env bash

@test cron_entry {
    ! contacts_is_running

    run ./kitout.sh tests/start.kitfile

    [ $status -eq 0 ]
    contacts_is_running
}

function contacts_is_running {
    ps x | grep '[/]Contacts.app/'
}

function setup_file {
    teardown
}

function teardown {
    pid=$(contacts_is_running | cut -d' ' -f1 )
    [ -n "$pid" ] && kill $pid || true
}
