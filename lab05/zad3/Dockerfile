ARG PYTHON_VERSION=3.9
FROM python:${PYTHON_VERSION}
COPY python-app /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
