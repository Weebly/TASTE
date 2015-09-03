FROM python:2.7.9-slim
RUN pip install flower==0.7.3
RUN pip install celery
ENTRYPOINT ["celery", "flower"]
