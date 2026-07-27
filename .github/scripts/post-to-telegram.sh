#!/usr/bin/env bash
# Posts a release to a Telegram channel: APK file when possible, otherwise a download link.
set -euo pipefail

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHANNEL_ID:-}" ]; then
  echo "Telegram secrets not configured — skipping channel post."
  exit 0
fi

APK_SOURCE="${APK_SOURCE:?APK_SOURCE is required}"
VERSION_NAME="${VERSION_NAME:?VERSION_NAME is required}"
VERSION_CODE="${VERSION_CODE:?VERSION_CODE is required}"
CAPTION_FILE="${CAPTION_FILE:?CAPTION_FILE is required}"

APK_NAME="kosherTelegram-${VERSION_NAME}-build${VERSION_CODE}.apk"
APK_PATH="/tmp/${APK_NAME}"
cp "$APK_SOURCE" "$APK_PATH"

BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
CHANNEL_ID="$TELEGRAM_CHANNEL_ID"

TELEGRAM_MAX_UPLOAD_BYTES=$((48 * 1024 * 1024))
API_BASE="https://api.telegram.org/bot${BOT_TOKEN}"

if [ ! -f "$APK_PATH" ]; then
  echo "APK not found at: $APK_PATH"
  exit 1
fi

if [ ! -f "$CAPTION_FILE" ]; then
  echo "Caption file not found at: $CAPTION_FILE"
  exit 1
fi

apk_size=$(stat -c%s "$APK_PATH")
apk_name=$(basename "$APK_PATH")
full_caption=$(cat "$CAPTION_FILE")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Telegram document captions are limited to 1024 characters.
document_caption=$(DOWNLOAD_URL="" "$SCRIPT_DIR/generate-release-notes.sh")
if [ "${#document_caption}" -gt 1024 ]; then
  document_caption="${document_caption:0:1021}..."
fi

echo "APK size: $apk_size bytes ($apk_name)"

post_document() {
  local response
  response=$(curl -sS -X POST "${API_BASE}/sendDocument" \
    -F "chat_id=${CHANNEL_ID}" \
    -F "document=@${APK_PATH};filename=${apk_name}" \
    -F "parse_mode=HTML" \
    --form-string "caption=${document_caption}")

  if echo "$response" | jq -e '.ok == true' > /dev/null; then
    echo "Posted APK document to Telegram channel."
    return 0
  fi

  echo "sendDocument failed: $response"
  return 1
}

post_message() {
  local response
  response=$(curl -sS -X POST "${API_BASE}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg chat_id "$CHANNEL_ID" \
      --arg text "$full_caption" \
      '{chat_id: $chat_id, parse_mode: "HTML", text: $text}')")

  if echo "$response" | jq -e '.ok == true' > /dev/null; then
    echo "Posted release message to Telegram channel."
    return 0
  fi

  echo "sendMessage failed: $response"
  return 1
}

if [ "$apk_size" -le "$TELEGRAM_MAX_UPLOAD_BYTES" ]; then
  echo "APK is within Telegram upload limit — sending as document."
  post_document
else
  echo "APK exceeds Telegram bot upload limit (48 MB) — sending release notes with download link."
  post_message
fi
