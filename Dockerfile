FROM python:3.9-buster@sha256:bd58aa2214ce6347a5bfb17d8af49c3425e041defc46c66adb6a025f44f4d21f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]