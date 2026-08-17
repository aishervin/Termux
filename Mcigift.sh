cat << 'EOF' > setup.py
import os, subprocess, sys

try:
    import jdatetime
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "jdatetime"])
    import jdatetime

m = jdatetime.date.today().month
d = jdatetime.date(jdatetime.date.today().year, m, 1)
if m == 12:
    d = jdatetime.date(jdatetime.date.today().year + 1, 1, 1) - jdatetime.timedelta(days=1)
else:
    d = jdatetime.date(jdatetime.date.today().year, m + 1, 1) - jdatetime.timedelta(days=1)

while d.weekday() != 0:
    d -= jdatetime.timedelta(days=1)

cron = f"0 10 {d.day} {d.month} * export LD_LIBRARY_PATH=/system/lib64:/system/lib; /usr/bin/am start -a android.intent.action.DIAL -d tel:*100*64*1%23"
os.system(f'(crontab -l 2>/dev/null | grep -v "am start" ; echo "{cron}") | crontab -')
EOF
python3 setup.py && rm setup.py
