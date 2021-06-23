FROM python:3.9-buster@sha256:e92dcaabd516e6a0dc9dc00a9beefc59082edf9955e771c6714009e23b6a5642

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]