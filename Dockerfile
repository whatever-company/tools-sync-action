FROM python:3.12-slim@sha256:da2d7af143dab7cd5b0d5a5c9545fe14e67fc24c394fcf1cf15e8ea16cbd8637

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
