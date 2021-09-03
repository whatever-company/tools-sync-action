FROM python:3.9-buster@sha256:66a4a98d3e3867c238902e18511d6ff779659b6100b4550d01fdfa37b7a2a7b1

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]