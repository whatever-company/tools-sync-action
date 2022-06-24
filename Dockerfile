FROM python:3.10-buster@sha256:6f0508d4cec08983035562343bb4f3c9611ccb5ff385b72eab51caa2dfdf2399

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]