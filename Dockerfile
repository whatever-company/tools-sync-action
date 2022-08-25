FROM python:3.10-buster@sha256:6ec5fc87e4628ac35d5cbb65afd8b97a94db40fec824cd66e5c326df43203127

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]