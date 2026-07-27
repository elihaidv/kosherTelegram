#!/usr/bin/env bash
# Generates bilingual HTML release notes for Telegram channel posts.
set -euo pipefail

VERSION_NAME="${VERSION_NAME:?VERSION_NAME is required}"
VERSION_CODE="${VERSION_CODE:?VERSION_CODE is required}"
COMMIT_SHA="${COMMIT_SHA:-unknown}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-No commit message}"
BRANCH="${BRANCH:-unknown}"
DOWNLOAD_URL="${DOWNLOAD_URL:-}"

# Keep commit message to one line and escape HTML entities for Telegram.
COMMIT_MESSAGE_SINGLE_LINE=$(echo "$COMMIT_MESSAGE" | head -n 1 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
SHORT_SHA="${COMMIT_SHA:0:7}"

DOWNLOAD_SECTION=""
if [ -n "$DOWNLOAD_URL" ]; then
  DOWNLOAD_SECTION=$'\n\n'"📥 <a href=\"${DOWNLOAD_URL}\">Download APK</a>"
fi

cat <<EOF
<b>🆕 kosherTelegram v${VERSION_NAME}</b> (Build #${VERSION_CODE})

${COMMIT_MESSAGE_SINGLE_LINE}

<code>${SHORT_SHA}</code> · ${BRANCH}

<b>What this fork does:</b>
• Shows only channels and chats already in your account
• Blocks discovering or joining new channels inside the app
• No content moderation or filtering — messages appear as sent
• Profile protection and no in-app browser

<b>Important:</b> This app does not review, filter, or moderate content.

<b>מה המזלג עושה:</b>
• מציג רק ערוצים וצ'אטים שכבר קיימים בחשבון
• חוסם גילוי והצטרפות לערוצים חדשים בתוך האפליקציה
• ללא סינון או מודרציה של תוכן — הודעות מוצגות כפי שנשלחו
• הגנה על פרופילים וללא דפדפן פנימי

<b>חשוב:</b> האפליקציה לא בודקת, מסננת או מפקחת על תוכן.${DOWNLOAD_SECTION}
EOF
