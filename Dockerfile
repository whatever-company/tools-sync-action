FROM python:3.9-buster@sha256:9ad0ac70f37fcdfda1ba54f87b61dca8a0ea7444c9a7b016460f81c1eb163133

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]