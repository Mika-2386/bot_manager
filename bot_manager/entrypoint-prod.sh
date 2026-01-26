#!/bin/sh

start_django() {
    echo "Collecting static files..."
    python manage.py collectstatic --noinput

    echo "Running migrations..."
    python manage.py migrate --noinput

    echo "Creating STT staff group..."
    python manage.py create_stt_staff_group || echo "Команда create_stt_staff_group не выполнена"

    echo "Creating STT general superuser..."
    python manage.py create_general_superuser || echo "Команда create_general_superuser не выполнена"

    echo "Setting up periodic tasks..."
    python manage.py setup_periodic_tasks || echo "Команда setup_periodic_tasks не выполнена"

    PORT=${PORT:-8000}
    GUNICORN_TIMEOUT=${GUNICORN_TIMEOUT:-30}

    echo "Starting server..."
    gunicorn --timeout "$GUNICORN_TIMEOUT" --workers 3 --threads 3 --bind 0.0.0.0:"$PORT" config.wsgi:application

    echo "Server has started!"
}

start_django
