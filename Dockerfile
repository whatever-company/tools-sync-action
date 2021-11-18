FROM python:3.10-buster@sha256:3670aba45b9b56f79271b241cab731dc65be85a2de031cccdeaf900ec22d9a81

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]