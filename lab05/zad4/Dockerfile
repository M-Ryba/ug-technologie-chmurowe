ARG PYTHON_VERSION=3.9

FROM python:${PYTHON_VERSION}-alpine

ARG APP_PORT=3000

RUN mkdir app

WORKDIR /app

VOLUME ["/app"]

ENV VIRTUAL_ENV=/app/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV APP_PORT=$APP_PORT

ADD python-app .

RUN pip install -r requirements.txt

EXPOSE ${APP_PORT}

CMD ["sh", "-c", "python app.py --port $APP_PORT"]
