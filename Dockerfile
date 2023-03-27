FROM python:3.11-buster@sha256:f95aa9e75b2304fbefaee5c1761a898b13a7014b3d66093b689f26f1e6160ba4
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
