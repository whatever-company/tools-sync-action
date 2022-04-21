FROM python:3.10-buster@sha256:e4f12962bbb8e0cd1e3614c1d1f228685aa7ab1d864ac029b1977ab9b0081e89

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]