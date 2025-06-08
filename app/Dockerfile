# 개발용
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install aiosqlite

# Set Python path
ENV PYTHONPATH=/app:$PYTHONPATH

# Copy start.sh first and make it executable
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create necessary directories with proper permissions
RUN mkdir -p /app/uploads /app/audio_files /app/static /app/logs \
    && chmod -R 777 /app/uploads /app/audio_files /app/static /app/logs

# Copy the rest of the application
COPY . .

# Set permissions for the application
RUN chown -R root:root /app \
    && chmod -R 755 /app \
    && chmod -R 777 /app/alembic/versions

CMD ["/app/start.sh"]



# 배포용
# FROM python:3.11
# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt
# COPY ./app /app
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]