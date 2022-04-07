FROM python:3.10-buster@sha256:8f39d868cb68cfb10cfce517a022436c017b32f5924d48be3c36108dffcab9dc

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]