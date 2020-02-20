FROM python:3.8-buster

RUN pip install poetry==1.0.3

COPY . /app
WORKDIR /app
RUN poetry install --no-dev


ENTRYPOINT ["python", "dev-sync.py"]