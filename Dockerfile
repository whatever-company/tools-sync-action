FROM python:3.9-buster@sha256:88e7df21c03536caeca064dd04a6cac7868b4fdf9e4d849e679e43718eea922c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]