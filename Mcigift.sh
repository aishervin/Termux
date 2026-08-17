#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Setup cron job for auto-dialing on the first Monday of each month
# ============================================================

set -e

echo "Checking and installing prerequisites..."
pkg install -y python crontab 2>/dev/null || {
    echo "Installing cronie or busybox..."
    pkg install -y cronie busybox 2>/dev/null || true
}

python3 - <<'PYTHON_SCRIPT'
import os
import subprocess
import sys

try:
    import jdatetime
except ImportError:
    print("Installing jdatetime...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "jdatetime"])
    import jdatetime

today = jdatetime.date.today()
year = today.year
month = today.month

if month == 12:
    last_day = jdatetime.date(year + 1, 1, 1) - jdatetime.timedelta(days=1)
else:
    last_day = jdatetime.date(year, month + 1, 1) - jdatetime.timedelta(days=1)

monday = last_day
while monday.weekday() != 0:
    monday -= jdatetime.timedelta(days=1)

cron_cmd = (
    f"0 10 {monday.day} {monday.month} * "
    "export LD_LIBRARY_PATH=/system/lib64:/system/lib; "
    "/usr/bin/am start -a android.intent.action.DIAL -d tel:\\*100\\*64\\*1\\%23"
)

try:
    result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
    current_cron = result.stdout if result.returncode == 0 else ""
    filtered_lines = [line for line in current_cron.splitlines() if 'am start' not in line]
    filtered_lines.append(cron_cmd)
    new_cron = '\n'.join(filtered_lines) + '\n'
    subprocess.run(['crontab', '-'], input=new_cron, text=True, check=True)
    print("Cron job set successfully:")
    print(f"   {cron_cmd}")
except FileNotFoundError:
    print("crontab not found. Please install cronie.")
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)

PYTHON_SCRIPT

echo "Script executed successfully."
