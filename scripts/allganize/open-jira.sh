#!/bin/bash

read -p "Enter JIRA ticket ID (ex: ALL-xxxx): " -r JIRA_TICKET_ID

open "https://allganize2.atlassian.net/browse/${JIRA_TICKET_ID}"
