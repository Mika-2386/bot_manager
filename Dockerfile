FROM python:3.13.2 as builder

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.7.1

# Обновляем пакеты и устанавливаем Poetry
RUN apt-get update && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install "poetry==$POETRY_VERSION"

# Копируем файлы зависимостей
COPY poetry.lock pyproject.toml ./


# Устанавливаем зависимости через poetry и экспортируем requirements.txt
RUN poetry config virtualenvs.create false && \
    poetry export -f requirements.txt --output requirements.txt --without-hashes && \
    pip wheel --wheel-dir=wheels -r requirements.txt


# Копируем приложение
COPY .. ./

# Даем права на запуск скрипта
RUN chmod +x ./entrypoint-prod.sh

FROM python:3.13.2

WORKDIR /app

ENV GUNICORN_TIMEOUT=0

# Устанавливаем зависимости из wheel-файлов
COPY --from=builder /app/wheels /wheels
RUN pip install --upgrade pip && \
    pip install /wheels/*.whl

# Копируем приложение
COPY .. ./

# Делаем скрипт исполняемым
RUN chmod +x ./entrypoint-prod.sh

CMD ["./entrypoint-prod.sh"]