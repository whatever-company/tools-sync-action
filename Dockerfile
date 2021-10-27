FROM python:3.10-buster@sha256:3bbc63ce96594dc3181567ad774c1dc8aec514760d65dae348a1b3a8254876d9

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]