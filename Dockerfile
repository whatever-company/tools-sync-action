FROM python:3.10-buster@sha256:bb670e7112fc1d95dd04aa95b30c7f838e46cff96eeeb5ac29774026336570e5

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]