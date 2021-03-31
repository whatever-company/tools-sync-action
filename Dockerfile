FROM python:3.9-buster@sha256:302e0a362b67eeb78de663e0ffbd3e4c03ac5cf0fcb69caff3c696f53aae2392

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]