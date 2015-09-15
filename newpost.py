from cookiecutter.main import cookiecutter
from datetime import datetime
from tzlocal import get_localzone
import pytz


cookiecutter(
    'cookiecutter-new-post',
    extra_context={
        'date': datetime.utcnow().replace(tzinfo=pytz.utc).astimezone(get_localzone()).strftime('%Y-%m-%d %H:%M')})
