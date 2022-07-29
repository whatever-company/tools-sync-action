FROM python:3.10-buster@sha256:aae9dc38e0f061f89d5c3132ecc1071f21dab2911be2d935ae32974506eff208

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]