#!/bin/bash

# 환경 변수 검증
echo "Checking environment variables..."

if [ -z "$AZURE_OPENAI_API_KEY" ]; then
    echo "Error: AZURE_OPENAI_API_KEY is not set"
    exit 1
fi

if [ -z "$AZURE_OPENAI_ENDPOINT" ]; then
    echo "Error: AZURE_OPENAI_ENDPOINT is not set"
    exit 1
fi

# API 버전과 deployment name이 설정되지 않은 경우 기본값 설정
export AZURE_OPENAI_API_VERSION=${AZURE_OPENAI_API_VERSION:-"2023-05-15"}
export AZURE_OPENAI_DEPLOYMENT_NAME=${AZURE_OPENAI_DEPLOYMENT_NAME:-"gpt-4"}

echo "Environment variables validated successfully"
echo "Starting dialogue service..."
echo "API Version: $AZURE_OPENAI_API_VERSION"
echo "Deployment Name: $AZURE_OPENAI_DEPLOYMENT_NAME"
echo "Endpoint: $AZURE_OPENAI_ENDPOINT"

exec uvicorn main:app --host 0.0.0.0 --port 5001 --reload 