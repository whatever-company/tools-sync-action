FROM python:3.9-buster@sha256:ff502166564b244ea6e8d5521f00bcded4b4db66010ae3657f92f2951e360bf8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]