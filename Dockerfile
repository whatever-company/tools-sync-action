FROM python:3.8-buster

RUN pip install poetry==1.0.3

COPY dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/app/dev-sync.py"]