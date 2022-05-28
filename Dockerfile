FROM python:3.10-buster@sha256:5bff8c5001892c351d260f33b9d21b7b9bc54271d367636c9eb0c433fdca6136

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]