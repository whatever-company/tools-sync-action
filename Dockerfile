FROM python:3.9-buster@sha256:fb1c1dd7be753925b6e7b6f72766c3ef0846798630d717c26510c62d72c1f904

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]