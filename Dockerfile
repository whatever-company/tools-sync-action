FROM python:3.10-buster@sha256:cec5ace74c21c2bd89829f49b5f7c25027047c90fa8335e27fc5e69462041b49

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]