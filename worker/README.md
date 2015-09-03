### Taste Worker

The worker should be run on each VM host.

Make sure you have python requirements installed (it is recommended that you use a virtualenv).

```
pip install -r requirements.txt
```

Start the worker

```
celery worker --app=tasks.app
```
