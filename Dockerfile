FROM python:3.9-buster@sha256:588f672694b3c9caa2be414b4cb2bbd089927f29ac984576acd47ab57b64de12

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]