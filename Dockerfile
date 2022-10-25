FROM python:3.10-buster@sha256:f0091194de104b43cfc3ff6954123ef0dcdeea3b456bae4626680e8e97d4ccf8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]