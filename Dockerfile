ARG PYTHON_VERSION=3.12.0
FROM python:${PYTHON_VERSION}-slim as base

RUN pip install flask

# Copy the source code into the container.
COPY app.py /app.py

# Expose the port that the application listens on.
EXPOSE 5000

# Run the application.
CMD ["python", "/app.py"]
