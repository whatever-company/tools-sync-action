FROM python:3.10-buster@sha256:126ddc1d8db9f4648e492e5ba4001f01a51ec1489e66d41ec5abc1da308afe88

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]