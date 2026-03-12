#!/usr/bin/env sh

# Usage: ./send_text.sh user|group <target_id> <text>

set -eu

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 user|group <target_id> <text>" >&2
  exit 1
fi

field1="$1"
field2="$2"
field3="$3"

case "$field1" in
  user|group)
    ;;
  *)
    echo "Error: field1 must be 'user' or 'group'." >&2
    exit 1
    ;;
esac

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/ShNapCat.sh"

# 构造文本消息段并发送
msg="$(napcat_msg_text "$field3")"
napcat_send_msg "$field1" "$field2" "$msg"
