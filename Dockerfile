FROM python:3.12 as builder

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Обновляем систему и устанавливаем необходимые системные библиотеки (по необходимости)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        && rm -rf /var/lib/apt/lists/*

# Обновляем pip
RUN pip install --upgrade pip

# Копируем файл зависимостей
COPY requirements.txt ./

# Устанавливаем зависимости из requirements.txt
RUN pip install -r requirements.txt

FROM python:3.12

WORKDIR /app

ENV GUNICORN_TIMEOUT=0

# Копируем установленные пакеты из стадии builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Копируем остальные файлы проекта
COPY . ./

# Устанавливаем права для запуска скрипта
RUN chmod +x ./entrypoint-prod.sh

# Запуск скрипта по умолчанию
CMD ["./entrypoint-prod.sh"]