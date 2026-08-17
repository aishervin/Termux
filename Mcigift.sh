#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Mcigift.sh - Auto-Dialer Setup for Termux
# ============================================================

set -e

echo "Initializing setup..."

# 1. Install dependencies
pkg update -y && pkg install -y python cronie busybox 2>/dev/null

# 2. Setup Crond in bashrc to ensure it runs on every session
if ! grep -q "crond" ~/.bashrc; then
    echo "crond -b 2>/dev/null || crond" >> ~/.bashrc
fi
crond -b 2>/dev/null || crond

# 3. Python Logic for Cron Calculation
python3 - <<'PYTHON_SCRIPT'
import os, subprocess, sys

try:
    import jdatetime
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "jdatetime"])
    import jdatetime

today = jdatetime.date.today()
if today.month == 12:
    last_day = jdatetime.date(today.year + 1, 1, 1) - jdatetime.timedelta(days=1)
else:
    last_day = jdatetime.date(today.year, today.month + 1, 1) - jdatetime.timedelta(days=1)

monday = last_day
while monday.weekday() != 0:
    monday -= jdatetime.timedelta(days=1)

cron_cmd = (
    f"0 10 {monday.day} {monday.month} * "
    "export LD_LIBRARY_PATH=/system/lib64:/system/lib; "
    "/usr/bin/am start -a android.intent.action.DIAL -d tel:*100*64*1\\%23"
)

try:
    result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
    current_cron = result.stdout if result.returncode == 0 else ""
    filtered_lines = [line for line in current_cron.splitlines() if 'am start' not in line]
    filtered_lines.append(cron_cmd)
    new_cron = '\n'.join(filtered_lines) + '\n'
    subprocess.run(['crontab', '-'], input=new_cron, text=True, check=True)
    print(f"Success! Task scheduled for: {monday.year}/{monday.month}/{monday.day} at 10:00")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
PYTHON_SCRIPT

echo "Setup complete. Crond is active."
