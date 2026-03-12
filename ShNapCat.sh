#!/usr/bin/env sh
# ShNapCat.sh - NapCatQQ OneBot 11 HTTP API 通用函数库
# 被其他脚本 source 后使用

set -eu

# ---- 加载配置 ----

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/ShNapCatConfig.ini"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck source=ShNapCatConfig.ini
. "$CONFIG_FILE"

# ---- 内部工具函数 ----

# 构造 Authorization 头（如果配置了 access_token）
_napcat_auth_header() {
  if [ -n "${napcat_access_token:-}" ]; then
    printf -- '-H\nAuthorization: Bearer %s' "$napcat_access_token"
  fi
}

# 通用 API 调用
# 用法: _napcat_call <endpoint> <json_body>
_napcat_call() {
  _endpoint="$1"
  _body="$2"

  if [ -n "${napcat_access_token:-}" ]; then
    curl -s -S -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${napcat_access_token}" \
      -d "$_body" \
      "${napcat_api_url}/${_endpoint}"
  else
    curl -s -S -X POST \
      -H "Content-Type: application/json" \
      -d "$_body" \
      "${napcat_api_url}/${_endpoint}"
  fi
}

# ---- 发送私聊消息 ----

# 用法: napcat_send_private_msg <user_id> <message_json_array>
# message_json_array 是 OneBot 11 消息段数组的 JSON 字符串
napcat_send_private_msg() {
  _user_id="$1"
  _message="$2"
  _napcat_call "send_private_msg" \
    "{\"user_id\":${_user_id},\"message\":${_message}}"
}

# ---- 发送群聊消息 ----

# 用法: napcat_send_group_msg <group_id> <message_json_array>
napcat_send_group_msg() {
  _group_id="$1"
  _message="$2"
  _napcat_call "send_group_msg" \
    "{\"group_id\":${_group_id},\"message\":${_message}}"
}

# ---- 发送消息（自动判断类型） ----

# 用法: napcat_send_msg <user|group> <target_id> <message_json_array>
napcat_send_msg() {
  _type="$1"
  _target_id="$2"
  _message="$3"

  case "$_type" in
    user)
      napcat_send_private_msg "$_target_id" "$_message"
      ;;
    group)
      napcat_send_group_msg "$_target_id" "$_message"
      ;;
    *)
      echo "Error: type must be 'user' or 'group', got '$_type'" >&2
      return 1
      ;;
  esac
}

# ---- 消息段构造辅助 ----

# 纯文本消息段
# 用法: napcat_msg_text <text>
napcat_msg_text() {
  _text="$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | awk '{printf "%s\\n", $0}' | sed '$ s/\\n$//')"
  printf '[{"type":"text","data":{"text":"%s"}}]' "$_text"
}

# 图片消息段
# 用法: napcat_msg_image <file_uri_or_path>
napcat_msg_image() {
  printf '[{"type":"image","data":{"file":"%s"}}]' "$1"
}

# 语音消息段
# 用法: napcat_msg_record <file_uri_or_path>
napcat_msg_record() {
  printf '[{"type":"record","data":{"file":"%s"}}]' "$1"
}

# 视频消息段
# 用法: napcat_msg_video <file_uri_or_path>
napcat_msg_video() {
  printf '[{"type":"video","data":{"file":"%s"}}]' "$1"
}

# 文件消息段
# 用法: napcat_msg_file <file_uri_or_path> [name]
napcat_msg_file() {
  if [ -n "${2:-}" ]; then
    printf '[{"type":"file","data":{"file":"%s","name":"%s"}}]' "$1" "$2"
  else
    printf '[{"type":"file","data":{"file":"%s"}}]' "$1"
  fi
}

# @某人消息段
# 用法: napcat_msg_at <qq_number|all>
napcat_msg_at() {
  printf '[{"type":"at","data":{"qq":"%s"}}]' "$1"
}

# ---- 暂存文件到 NapCat temp 目录 ----

# 将本地文件复制到 NapCat 临时目录，返回 file:// URI
# 用法: napcat_stage_file <source_path>
napcat_stage_file() {
  _src="$1"

  if [ ! -f "$_src" ]; then
    echo "Error: source file not found: $_src" >&2
    return 1
  fi

  if [ ! -d "$napcat_temp_dir" ]; then
    echo "Error: NapCat temp dir not found: $napcat_temp_dir" >&2
    return 1
  fi

  _basename="$(basename "$_src")"
  _ext="${_basename##*.}"

  case "$_basename" in
    *.*) _staged="$napcat_temp_dir/shnapcat_${$}_$(date +%s).$_ext" ;;
    *)   _staged="$napcat_temp_dir/shnapcat_${$}_$(date +%s)" ;;
  esac

  cp "$_src" "$_staged"
  printf 'file://%s' "$_staged"
}