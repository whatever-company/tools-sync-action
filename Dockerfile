FROM python:3.10-buster@sha256:7be64a46b6ed741be6808696705197ae07816c3ec4e48b5fe013cac3a1da34df

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]