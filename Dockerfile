FROM python:3.13 as builder

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.7.1

RUN apt-get update && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-dev --no-interaction --no-ansi

FROM python:3.13

WORKDIR /app

ENV GUNICORN_TIMEOUT=0

# Копируем установленные пакеты из билда
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Копируем все файлы проекта
COPY . ./

# Устанавливаем права на скрипт
RUN chmod +x ./entrypoint-prod.sh

# Указываем команду запуска
CMD ["./entrypoint-prod.sh"]
