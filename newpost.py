from cookiecutter.main import cookiecutter
from datetime import datetime


cookiecutter(
    'cookiecutter-new-post',
    extra_context={'date': datetime.utcnow().strftime('%Y-%m-%d %H:%M')})
