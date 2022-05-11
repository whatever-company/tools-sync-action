FROM python:3.10-buster@sha256:20bfe417a1f7e18e49d9db58c2f54ce5c49755241eee6b089774c912630510f8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]