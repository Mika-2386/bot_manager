FROM python:3.13.2 as builder

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.7.1

RUN apt-get update && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install "poetry==$POETRY_VERSION"

COPY poetry.lock pyproject.toml ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-dev --no-interaction --no-ansi

FROM python:3.13.2

WORKDIR /app

ENV GUNICORN_TIMEOUT=0

COPY --from=builder /usr/local/lib/python3.13.2/site-packages /usr/local/lib/python3.13.2/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY .. ./

RUN chmod +x ./entrypoint-prod.sh

CMD ["./entrypoint-prod.sh"]
