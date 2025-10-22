#!/bin/bash

# Define the unique part of the tunnel command for identification
TUNNEL_CMD_SIG="ssh -o StrictHostKeyChecking=no -T -R 80:localhost:8000 serveo.net"
LOG_FILE="tunnel.log"

# --- Function to Stop the Tunnel ---
stop_tunnel() {
    echo "Stopping tunnel service by command signature..."
    pkill -f "$TUNNEL_CMD_SIG"
    
    # Check if the process was actually running
    if [ $? -eq 0 ]; then
        echo "Tunnel service terminated successfully."
    else
        echo "No matching tunnel service found running."
    fi
    
    # Clean up log file
    rm -f "$LOG_FILE"
    echo "Cleaned up log file: $LOG_FILE"
}

# --- Function to Start the Tunnel ---
start_tunnel() {
    # Check and kill any existing process first
    stop_tunnel
    
    # Start the SSH tunnel in the background
    # nohup: prevents the process from being killed if the shell hangsup
    # > $LOG_FILE 2>&1: redirects both standard output and error to the log file
    # &: puts the process in the background
    nohup $TUNNEL_CMD_SIG > "$LOG_FILE" 2>&1 &

    # Capture the Process ID (PID) of the last background command
    PID=$!

    echo "Tunnel process started in the background with PID: $PID."
    echo "Waiting 5 seconds for the public URL to be generated..."
    sleep 5

    echo -e "\n--- Tunnel Output ---"
    cat "$LOG_FILE"
    echo -e "\nLook for a URL in the output above (e.g., https://something.serveo.net). This is your public UI address."
}

# --- Main Logic ---
ACTION=${1:-start} # Default action is 'start' if no argument is provided

case "$ACTION" in
    start)
        start_tunnel
        ;;
    stop|kill)
        stop_tunnel
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
