# Этап сборки зависимостей и окружения
FROM python:3.12 as builder

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.7.1

# Обновляем пакеты и устанавливаем Poetry
RUN apt-get update && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install "poetry==$POETRY_VERSION"

# Копируем файлы для установки зависимостей
COPY poetry.lock pyproject.toml ./

# Устанавливаем зависимости без виртуальных окружений
RUN poetry config virtualenvs.create false && \
    poetry install --no-dev --no-interaction --no-ansi

# Устанавливаем Celery
RUN pip install celery

# Этап для сборки wheel-файлов
FROM python:3.12 as wheel-builder

WORKDIR /app

# Копируем проект из предыдущего этапа
COPY --from=builder /app /app

# Создаём папку для wheel-файлов
RUN mkdir /app/wheels

# Генерируем wheel-файлы из всех зависимостей
# Для этого нужен файл requirements.txt, который вы создаете в этапе build
# однако в вашем Dockerfile его нет, поэтому добавлю команду для генерации requirements.txt
# Перед этим нужно убедиться, что requirements.txt есть или создать его командой
COPY poetry.lock pyproject.toml ./
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# Генерируем wheel-файлы
RUN pip wheel --wheel-dir=/app/wheels -r requirements.txt

# Основной финальный образ
FROM python:3.12

WORKDIR /app

ENV GUNICORN_TIMEOUT=0

# Копируем установленные пакеты из builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Копируем wheel-файлы
COPY --from=wheel-builder /app/wheels /wheels

# Проверка содержимого папки /wheels
RUN ls -l /wheels

# Копируем весь проект
COPY . ./

# Сделать скрипт исполняемым
RUN chmod +x ./entrypoint-prod.sh

# Устанавливаем зависимости из wheel-файлов
RUN pip install --upgrade pip && \
    pip install /wheels/*.whl

CMD ["./entrypoint-prod.sh"]