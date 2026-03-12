# NapCatQQ-sh

基于 NapCatQQ OneBot 11 HTTP API 的 shell 脚本工具集，用于通过命令行发送 QQ 消息。

## 前提条件

- 已安装并运行 [NapCatQQ](https://napneko.github.io/)，且开启了 HTTP 服务
- 系统中可用 `curl` 命令

## 配置文件

编辑 `ShNapCatConfig.ini`：

```ini
# NapCat HTTP API 地址
napcat_api_url="http://127.0.0.1:3000"

# HTTP API 访问令牌（若未设置鉴权可留空）
napcat_access_token=""

# 媒体文件存储目录
emoji_dir="/path/to/your/emoji"

# NapCat 临时文件目录（macOS QQ 沙箱路径）
napcat_temp_dir="/path/to/QQ/NapCat/temp"
```

## 脚本说明

### ShNapCat.sh — 公共函数库

被其他脚本 `source` 加载，提供：

- `napcat_send_msg user|group <id> <message_json>` — 发送消息
- `napcat_msg_text <文本>` — 构造文本消息段
- `napcat_msg_image <file_uri>` — 构造图片消息段
- `napcat_msg_record <file_uri>` — 构造语音消息段
- `napcat_msg_video <file_uri>` — 构造视频消息段
- `napcat_msg_file <file_uri> [文件名]` — 构造文件消息段
- `napcat_msg_at <QQ号|all>` — 构造 @消息段
- `napcat_stage_file <本地路径>` — 将文件复制到 NapCat temp 目录，返回 `file://` URI

### send_text.sh — 发送文本消息

```sh
./send_text.sh user|group <目标ID> <文本内容>
```

示例：

```sh
./send_text.sh user 123456 "你好"
./send_text.sh group 654321 "大家好"
```

### send_media.sh — 发送媒体消息

```sh
./send_media.sh user|group <目标ID> <文件名> [image|record|video|file]
```

第4个参数可选，默认为 `image`。文件从 `emoji_dir` 目录读取。

示例：

```sh
./send_media.sh user 123456 cat.gif
./send_media.sh group 654321 hello.mp4 video
./send_media.sh user 123456 doc.pdf file
```

## 消息上报

参考链接 https://napneko.github.io/develop/msg
