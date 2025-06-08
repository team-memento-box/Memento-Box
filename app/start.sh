#!/bin/bash

# Function to wait for a service
wait_for_service() {
    local service=$1
    local url=$2
    local timeout=$3
    local start_time=$(date +%s)

    echo "Waiting for $service..."
    while ! curl -s "$url" > /dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $timeout ]; then
            echo "Timeout waiting for $service after ${timeout}s"
            return 1
        fi
        echo "Waiting for $service... ($elapsed seconds)"
        sleep 5
    done
    echo "$service is available"
    return 0
}

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
until pg_isready -h db -p 5432 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > /dev/null 2>&1; do
    echo "Waiting for PostgreSQL... ($(date))"
    sleep 5
done
echo "PostgreSQL is available"

# Run database migrations
echo "Running database migrations..."
alembic upgrade head

# Start FastAPI application
echo "Starting FastAPI application..."
exec uvicorn main:app --host 0.0.0.0 --port 8000 --reload 