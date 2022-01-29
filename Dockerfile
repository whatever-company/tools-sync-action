FROM python:3.10-buster@sha256:25f24c6bc99fc0bb74de704b437b8b69fc1ea2a6f6611c55dc1e1d733ceac95b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]