FROM python:3.10-buster@sha256:7d1cb18b0ec183156df67aeb05edaeef8c619009962fb19e68267df3272ed371

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]