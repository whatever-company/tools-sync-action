FROM python:3.10-buster@sha256:da8a438e11f27d56efada140572c61c6ce7c89b047d6a7155ac13bb07d1d7d55

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]