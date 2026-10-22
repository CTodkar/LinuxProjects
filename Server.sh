#File to scan a server healt check
#!/bin/bash

echo "=========================================="
echo "         SYSTEM RESOURCE MONITOR"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "Date: $(date)"


# 1. Total CPU Usage
echo "========== TOTAL CPU USAGE =========="

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'.' -f1)

if [[ -n "$CPU_IDLE" ]]; then
    CPU_USAGE=$((100 - CPU_IDLE))
    echo "Total CPU Usage: ${CPU_USAGE}%"
else
    echo "Unable to determine CPU usage."
fi
echo

# 2. Total Memory Usage (Free vs Used)
echo "========== MEMORY USAGE =========="

free -m | awk '/^Mem:/ {
    total = $2
    used = $3
    available = $7
    free_mem = total - available

    if (total > 0) {
        printf "Total Memory:     %d MB\n", total
        printf "Used Memory:      %d MB (%.2f%%)\n", used, used/total*100
        printf "Available Memory: %d MB (%.2f%%)\n", available, available/total*100
        printf "Free Memory:      %d MB\n", free_mem
    }
}'
echo

# 3. Total Disk Usage (Free vs Used)
echo "========== DISK USAGE =========="

df -hP --total | awk '
    $1 == "total" {
        printf "Total Disk: %s\n", $2
        printf "Used Disk:  %s (%s)\n", $3, $5
        printf "Free Disk:  %s (%s)\n", $4, 100-$5+0 "%"
    }
'

# Show individual filesystem usage
echo
echo "Individual Filesystem Usage:"
df -hP -x tmpfs -x devtmpfs
echo

# 4. Top 5 Processes by CPU Usage
echo "========== TOP 5 PROCESSES BY CPU =========="

ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
echo

# 5. Top 5 Processes by Memory Usage
echo "========== TOP 5 PROCESSES BY MEMORY =========="

ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6
echo

echo "=========================================="
echo "       MONITORING COMPLETED"
echo "=========================================="
