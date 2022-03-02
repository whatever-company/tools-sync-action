FROM python:3.10-buster@sha256:03eb4137ba71b1ee71e1600889b1de9d620cb5b66bfa47c435ca16be8f8b92fc

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]