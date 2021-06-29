FROM python:3.9-buster@sha256:bb738a13e61033430204bc70344a87f4db911c024bb5374d71dd94646ac46d67

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]