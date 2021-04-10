FROM python:3.9-buster@sha256:acc44253c21eb6a7301988c1732cddff6501298f58d688ee4b69b51e3d1ba766

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]