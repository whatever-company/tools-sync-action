FROM python:3.9-buster@sha256:3d94077b290cbaf46f720801ecc8bf608065c6adbe7153dfc2a76de03db541cf

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]