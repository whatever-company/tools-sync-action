FROM python:3.10-buster@sha256:9c46804abb6522b4fa97c465d43ea4918dbad7be4d1110175139180b071549f3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]