FROM python:3.10-buster@sha256:68e52205cab61d6b55fc35f31d234fbf2cbeb5335c56a6fc219befdbab08c94a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]