FROM python:3.9-buster@sha256:bc3dfd29271a8b0992fc3c81c0ad1a04adb56d97c20bac81b4a767b514344589

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]