FROM python:3.13-alpine

WORKDIR /app

COPY app.py /app

RUN pip install --no-cache-dir flask pymongo

EXPOSE 3003

CMD ["python", "app.py"]
