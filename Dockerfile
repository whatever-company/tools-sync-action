FROM python:3.10-buster@sha256:35a56c7a77cd7ce3fc35054018feef4af826b158c4f926b853ca8c4cc3a315ce

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]