FROM python:3.10-buster@sha256:bb76a025d1ba1820c33197637d21484e439347cb18c59d1858f06425d0a3b403

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]