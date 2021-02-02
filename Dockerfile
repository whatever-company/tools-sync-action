FROM python:3.9-buster@sha256:2b0c1a3dce71b6df50d3b157aad9286ed3cb4116244b8af1be76845f565187f2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]