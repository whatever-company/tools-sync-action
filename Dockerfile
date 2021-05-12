FROM python:3.9-buster@sha256:28b181eb6a94d2a66020a0e6f178e36a72d16f6356144241ab1cf28a71aae152

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]