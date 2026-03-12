#!/usr/bin/env sh

# Usage: ./send_media.sh user|group <target_id> <file_name>

set -eu

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 user|group <target_id> <file_name>" >&2
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

emoji_dir="/Users/dataneko/.openclaw/workspace/emoji"
media_path="$emoji_dir/$field3"
napcat_temp_dir="/Users/dataneko/Library/Containers/com.tencent.qq/Data/.config/QQ/NapCat/temp"

if [ ! -f "$media_path" ]; then
  echo "Error: file not found: $media_path" >&2
  exit 1
fi

if [ ! -d "$napcat_temp_dir" ]; then
  echo "Error: NapCat temp dir not found: $napcat_temp_dir" >&2
  exit 1
fi

ext="${field3##*.}"
case "$field3" in
  *.*) staged_file="$napcat_temp_dir/openclaw_${$}_$(date +%s).$ext" ;;
  *) staged_file="$napcat_temp_dir/openclaw_${$}_$(date +%s)" ;;
esac

# Stage file into QQ/NapCat container path to avoid sandbox copy restrictions.
cp "$media_path" "$staged_file"

openclaw-cn message send \
  --channel onebot \
  --target "$field1:$field2" \
  --media "file://$staged_file"
