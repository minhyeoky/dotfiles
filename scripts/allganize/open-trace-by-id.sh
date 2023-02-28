#!/bin/bash

read -p "Enter Trace ID: " -r TRACE_ID

from_ts=$(python3 -c "from datetime import datetime; from datetime import timedelta; print(int((datetime.now() - timedelta(weeks=2)).timestamp() * 1000))")
to_ts=$(python3 -c "from datetime import datetime; print(int(datetime.now().timestamp() * 1000))")

echo "Opening Datadog Logs for Trace ID: ${TRACE_ID}. From=<${from_ts}>,To=<${to_ts}>"
open "https://app.datadoghq.com/logs?query=%40trace_id%3A${TRACE_ID}&cols=host%2Cservice&index=%2A&messageDisplay=inline&stream_sort=time%2Cdesc&viz=stream&from_ts=${from_ts}&to_ts=${to_ts}&live=true"
