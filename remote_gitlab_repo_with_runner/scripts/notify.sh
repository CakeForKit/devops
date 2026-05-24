#!/bin/bash
set -e

PIPELINE_ID=$1
PROJECT_ID=$2

if [ -z "$PIPELINE_ID" ] || [ -z "$PROJECT_ID" ]; then
    echo "Usage: $0 <pipeline_id> <project_id>"
    exit 1
fi

GITLAB_URL="https://git.iu7.bmstu.ru"

echo "Fetching jobs for pipeline $PIPELINE_ID..."

if [ -z "$GITLAB_API_TOKEN" ]; then
    echo "ERROR: GITLAB_API_TOKEN not set!"
    exit 1
fi

if [ -z "$EMAIL_TO" ]; then
    echo "ERROR: EMAIL_TO not set!"
    exit 1
fi


# Получаем информацию о джобах через API GitLab
JOBS_JSON=$(curl -s --fail \
    --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines/$PIPELINE_ID/jobs")


# Получаем информацию о пайплайне
PIPELINE_JSON=$(curl -s --fail \
    --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines/$PIPELINE_ID")

PIPELINE_STATUS=$(echo "$PIPELINE_JSON" | jq -r '.status')
BRANCH=$(echo "$PIPELINE_JSON" | jq -r '.ref')

# Формируем HTML письмо
SUBJECT="Pipeline $PIPELINE_STATUS: $CI_PROJECT_NAME #$PIPELINE_ID"

BODY="Pipeline Result for $CI_PROJECT_NAME

Branch: $BRANCH
Status: $PIPELINE_STATUS
Pipeline: #$PIPELINE_ID
URL: $CI_PIPELINE_URL

Jobs:
"
JOBS_LIST=$(echo "$JOBS_JSON" | jq -r '.[] | "  - \(.name): \(.status)"' 2>/dev/null || echo "  (no jobs data)")
BODY="$BODY$JOBS_LIST"

echo "Sending email notification..."

echo "$BODY" | mail  -a "From: katherine_2022@mail.ru" -s "$SUBJECT" "$EMAIL_TO"

echo "Email notification sent to $EMAIL_TO!"


# EMAIL_TO	Variable	kate@example.com — куда отправлять
# EMAIL_FROM	Variable	gitlab@example.com — от кого
# SMTP_PASSWORD	Masked	Пароль от почты (если нужен)