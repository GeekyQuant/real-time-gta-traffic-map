FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8

WORKDIR /app

COPY requirements.txt /app
## Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

COPY . /app

ENV PYTHONPATH "${PYTHONPATH}:/app/app"

CMD [ "uvicorn", "app.main:app", "--reload", "--host", "0.0.0.0", "--port", "8000" ]