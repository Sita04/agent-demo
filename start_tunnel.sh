#!/bin/bash

# Define the log file
LOG_FILE="tunnel.log"

# Kill any existing ssh tunnel processes to avoid conflicts if re-run
pkill -f "ssh -o StrictHostKeyChecking=no -T -R 80:localhost:8000 serveo.net"

# Start the SSH tunnel in the background
# nohup: prevents the process from being killed if the shell hangsup
# > $LOG_FILE 2>&1: redirects both standard output and error to the log file
# &: puts the process in the background
nohup ssh -o StrictHostKeyChecking=no -T -R 80:localhost:8000 serveo.net > "$LOG_FILE" 2>&1 &

# Capture the Process ID (PID) of the last background command
PID=$!

echo "Tunnel process started in the background with PID: $PID."
echo "Waiting 5 seconds for the public URL to be generated..."
sleep 5

echo -e "\n--- Tunnel Output ---"
cat "$LOG_FILE"
echo -e "\nLook for a URL in the output above (e.g., https://something.serveo.net). This is your public UI address."
