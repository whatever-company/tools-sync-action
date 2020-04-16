FROM python:3.8-buster@sha256:dc0a6632bd548493e597f668610a9b3ba86b3e8cdf3b13cf00d7bdc6e2f45081

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]