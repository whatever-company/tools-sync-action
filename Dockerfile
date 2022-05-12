FROM python:3.10-buster@sha256:b11ea5ef4f5d66e5387509e75020a1edb67cafb03b55a1d26b2e680349b21bc4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]