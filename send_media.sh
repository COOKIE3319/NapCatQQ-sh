#!/usr/bin/env sh

# Usage: ./send_media.sh user|group <target_id> <file_name> [media_type]
# media_type: image(default), record, video, file

set -eu

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 user|group <target_id> <file_name> [image|record|video|file]" >&2
  exit 1
fi

field1="$1"
field2="$2"
field3="$3"
media_type="${4:-image}"

case "$field1" in
  user|group)
    ;;
  *)
    echo "Error: field1 must be 'user' or 'group'." >&2
    exit 1
    ;;
esac

case "$media_type" in
  image|record|video|file)
    ;;
  *)
    echo "Error: media_type must be 'image', 'record', 'video' or 'file'." >&2
    exit 1
    ;;
esac

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/ShNapCat.sh"

media_path="$emoji_dir/$field3"

# 将文件暂存到 NapCat temp 目录并获取 file:// URI
staged_uri="$(napcat_stage_file "$media_path")"

# 根据媒体类型构造消息段
case "$media_type" in
  image)  msg="$(napcat_msg_image "$staged_uri")" ;;
  record) msg="$(napcat_msg_record "$staged_uri")" ;;
  video)  msg="$(napcat_msg_video "$staged_uri")" ;;
  file)   msg="$(napcat_msg_file "$staged_uri" "$field3")" ;;
esac

# 发送消息
napcat_send_msg "$field1" "$field2" "$msg"
