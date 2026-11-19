#!/bin/bash

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_DIR/health.log"
ALERT_SCRIPT="$PROJECT_DIR/alert_bot.py"
DISK_THRESHOLD=80
MEM_THRESHOLD=80

# 1. Capture Timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 2. Extract System Metrics
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
MEM_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)

# 3. Log Metrics
LOG_ENTRY="[$TIMESTAMP] CPU Load: $CPU_LOAD | Memory: ${MEM_USAGE}% | Disk: ${DISK_USAGE}%"
echo "$LOG_ENTRY" >> "$LOG_FILE"
echo "$LOG_ENTRY"

# 4. Threshold Checks & Discord Triggers
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    ALERT_MSG="Critical Disk Usage on AWS EC2: ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)"
    echo "$ALERT_MSG"
    python3 "$ALERT_SCRIPT" "$ALERT_MSG"
fi

if [ "$MEM_USAGE" -ge "$MEM_THRESHOLD" ]; then
    ALERT_MSG="Critical Memory Usage on AWS EC2: ${MEM_USAGE}% (Threshold: ${MEM_THRESHOLD}%)"
    echo "$ALERT_MSG"
    python3 "$ALERT_SCRIPT" "$ALERT_MSG"
fi
