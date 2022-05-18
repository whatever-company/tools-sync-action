FROM python:3.10-buster@sha256:30a101ac6b62b2be5ec494f4b6e65851b75ab672b50fc2194e81f7e3028e105d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]