FROM python:3.9-buster@sha256:d7ab1c03ddc80fb87e280dee3a4ac55c7c7a162c961598e30b852d602d79ff91

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]