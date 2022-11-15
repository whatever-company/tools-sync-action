FROM python:3.11-buster@sha256:64242022e7692263ae50577362b542468f192c3ae9ea9f4fa75d442a9a35221d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]