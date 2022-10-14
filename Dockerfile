FROM python:3.10-buster@sha256:c73d259b4932abaf7134978def78e52de8833a0880437c4861e9abc3c6488fb2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]