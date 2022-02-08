FROM python:3.10-buster@sha256:33c420e065ca413a7e2deb2443b87fe5aef6e78926b623719dd38491b91640ac

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]