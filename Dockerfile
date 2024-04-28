ARG PYTHON_VERSION=3.12.0

FROM python:${PYTHON_VERSION}-slim as builder
WORKDIR /app

RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev
COPY src/ .

FROM python:${PYTHON_VERSION}-slim as runtime
WORKDIR /app
COPY --from=builder /app /app

# Expose the port that the application listens on.
EXPOSE 5000

# Run the application.
CMD ["python", "/app.py"]
