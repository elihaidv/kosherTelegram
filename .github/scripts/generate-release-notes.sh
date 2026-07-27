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

<b>What's new in this fork:</b>
• Profile protection — initials instead of photos in comments
• No in-app browser — all links open externally
• Reduced search and profile discovery

<b>מה כלול במזלג:</b>
• הגנה על פרופילים — אותיות ראשונות במקום תמונות בתגובות
• ללא דפדפן פנימי — כל הקישורים נפתחים בדפדפן חיצוני
• פחות חיפוש וגילוי פרופילים${DOWNLOAD_SECTION}
EOF
