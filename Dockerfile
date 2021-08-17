FROM python:3.9-buster@sha256:5edbc5487ba1f4f2a826bab0539c9006d1588a9cdd41cdae4f05e7906689dcc4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]