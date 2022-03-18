FROM python:3.10-buster@sha256:f085d3405dd3c203cdfb75382d561cfebe8d9a92c3ef5647addf09fe60abd4d3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]