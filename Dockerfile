FROM python:3.10-buster@sha256:c5be87e66e35f1848b86c441961c806ef2b009ab2647928d59834e4287fd5694

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]