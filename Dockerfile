FROM python:3.9-buster@sha256:361fdc5abde0666f8c9be3c53d292928765c4649203d117376c42e0cbd312991

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]