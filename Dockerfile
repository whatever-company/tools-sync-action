FROM python:3.10-buster@sha256:a1a8f866381a7131c37e8ba7f7014dc3c832aca47dde8b7098df2db651dfc77b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]