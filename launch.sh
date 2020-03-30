#!/bin/sh

if [ -z "$TO_REF" ]; then
    /app/dev-sync.py from_productboard to_github
else
    /app/dev-sync.py from_github to_productboard to_zendesk to_slack to_datadog
fi
