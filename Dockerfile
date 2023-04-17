FROM python:3.11-buster@sha256:4e4b336395c9654b1374a1275411ca2461610b301197ec74c889b13b10a8e47d
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install poetry and virtualenv
COPY poetry-requirements.txt pip-requirements.txt /
RUN pip install --no-cache-dir -r /poetry-requirements.txt -r pip-requirements.txt \
    && rm -rf /root/.cache

# Setup our virtualenv workdir and PATH
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false

COPY pyproject.toml .
COPY poetry.lock .

RUN poetry install --only main \
        && rm -rf /root/.cache

COPY launch.sh dev-sync.py /app/

ENTRYPOINT ["/bin/sh", "/app/launch.sh"]
