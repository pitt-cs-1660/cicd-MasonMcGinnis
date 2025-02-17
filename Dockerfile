FROM python:3.11-buster as builder
WORKDIR /app

# Install dependencies
RUN pip install --upgrade pip && pip install poetry

# Copy dependency files and install dependencies
COPY pyproject.toml poetry.lock /app/
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction --no-ansi

# Copy application code after installing dependencies
COPY . /app/
FROM python:3.11-buster as app
WORKDIR /app

# Copy application files and installed dependencies
COPY --from=builder /app /app
COPY --from=builder /usr/local /usr/local

# Copy and set permissions for entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose port for FastAPI
EXPOSE 8000

# Set entrypoint and command
ENTRYPOINT ["./entrypoint.sh"]
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]


