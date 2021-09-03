FROM python:3.9-buster@sha256:69e9de3da2fad9e717f2365a7ef1db13e54f02f83cd808481537e21d62b4606a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]