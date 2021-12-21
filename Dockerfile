FROM python:3.10-buster@sha256:96fe596e9e29d5e96ca4e2a7691548c96a01f4c1844bae000547ae493f8b1652

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]