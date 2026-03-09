---
name: wxauto
description: "微信自动化操作。通过 wxautox4 RESTful API 实现发送消息、获取聊天记录、监听消息、好友管理等功能。Use when: (1) 发送微信消息给好友或群聊，(2) 读取微信聊天记录，(3) 监听新消息，(4) 获取好友列表或群聊列表，(5) 接受好友申请，(6) 切换聊天窗口等微信操作。"
metadata:
  {
    "openclaw":
      {
        "emoji": "💬",
        "requires": { "bins": ["python"] },
        "install":
          [
            {
              "id": "pip-wxautox4",
              "kind": "pip",
              "package": "wxautox4",
              "label": "Install wxautox4 (pip)",
            },
          ],
      },
  }
---

# 微信自动化

通过本地 HTTP 服务操作微信，支持消息收发、监听、好友管理等功能。

## 前置要求

1. **安装 wxautox4**：
   
   ```bash
   pip install wxautox4
   ```
   
   > 注意：需windows系统，python3.9,3.10,3.11,3.12 64位，其他python版本暂不支持
   
2. **激活 wxautox4**：

   ```bash
   wxautox4 -a your-activation-code
   ```

   > 获取：https://docs.wxauto.org/plus

3. **部署 API 服务**：

   - 克隆项目：https://github.com/cluic/wxauto-restful-api
   - 配置 `config.yaml`
   - 启动服务：`python run.py`

## 服务配置

- 认证：Bearer Token（见 `config.yaml` 的 `auth.token`，默认值为 `token`）
- 服务状态文件：`~/.wxautox/service_status.json`（服务启动时自动生成，请查看该文件获取服务信息）

### 自动配置检测

服务启动后会自动将运行信息写入 `~/.wxautox/service_status.json`。wxapi.py 脚本会：
1. 自动读取此文件获取连接配置
2. 验证服务是否真的在运行（通过 API 健康检查）
3. 如果服务未运行，自动启动服务（需要服务目录存在）

服务目录搜索顺序：
- `../wxauto-restful-api`（相对于 skill 目录）
- `~/wxauto-restful-api`
- `WXAPI_SERVICE_DIR` 环境变量指定的路径

### 手动配置方式（可选）

如果需要覆盖自动配置，优先级从高到低：

1. **命令行参数**
   ```powershell
   python wxapi.py --base-url "http://localhost:9000" --token "my-token" send "好友" "消息"
   ```

2. **环境变量**
   
   ```powershell
   $env:WXAPI_BASE_URL = "http://localhost:9000"
   $env:WXAPI_TOKEN = "my-token"
   # 或者
   $env:WXAPI_PORT = "9000"
   $env:WXAPI_SERVICE_DIR = "/path/to/wxauto-restful-api"
   ```

3. **service_status.json** - 自动检测（推荐）

4. **config.yaml** - 服务目录下的配置文件

5. **默认值** - `http://localhost:8000`, token 为 `token`

## 启动服务

首次使用前需要启动服务：

```powershell
# 进入服务目录
cd /path/to/wxauto-restful-api
```

# 启动服务
```
python run.py
```

或后台启动（Windows）：

```powershell
Start-Process python -ArgumentList "run.py" -WorkingDirectory "C:\path\to\wxauto-restful-api" -WindowStyle Hidden
```

如果服务已运行，脚本会自动连接；如果服务未运行且配置了服务目录，脚本会自动启动服务。

## 脚本路径

Python 调用脚本位于 skill 目录下的 `scripts/wxapi.py`。

使用 `{baseDir}` 引用 skill 目录：
```powershell
python "{baseDir}/scripts/wxapi.py" send "好友" "消息"
```

## 可用命令

### 初始化和状态

```powershell
# 初始化微信实例
python wxapi.py init

# 获取服务状态
python wxapi.py status

# 检查是否在线
python wxapi.py online

# 获取我的信息
python wxapi.py myinfo
```

### 发送消息

```powershell
# 主窗口发送
python wxapi.py send "好友名" "消息内容"

# 精确匹配
python wxapi.py send "好友名" "消息内容" --exact

# @群成员
python wxapi.py send "群名" "开会了" --at "张三,李四"

# 子窗口发送
python wxapi.py send-chat "好友名" "消息内容"
```

### 读取消息

```powershell
# 获取聊天记录（主窗口）
python wxapi.py getmsg "好友名"

# 获取聊天记录（子窗口）
python wxapi.py getmsg-chat "好友名"

# 获取历史消息
python wxapi.py history "好友名" --count 100

# 获取新消息（主窗口轮询）
python wxapi.py newmsg

# 获取新消息（子窗口）
python wxapi.py newmsg-chat "好友名"
```

### 监听管理

```powershell
# 添加监听（打开子窗口）
python wxapi.py listen "好友名"
```

### 会话管理

```powershell
# 获取会话列表
python wxapi.py session

# 获取所有子窗口
python wxapi.py windows

# 切换聊天窗口
python wxapi.py chatwith "好友名" --exact
```

### 获取列表

```powershell
# 好友列表
python wxapi.py friends

# 群聊列表
python wxapi.py groups
```

### 页面控制

```powershell
# 切换到聊天页面
python wxapi.py switch-chat

# 切换到联系人页面
python wxapi.py switch-contact
```

### 查看帮助

```powershell
python wxapi.py --help
```

## API 接口列表

根据 wxauto-restful-api 服务：

### 微信功能接口

| 接口 | 说明 |
|------|------|
| `POST /v1/wechat/initialize` | 初始化微信实例 |
| `GET /v1/wechat/status` | 获取微信状态 |
| `POST /v1/wechat/send` | 发送消息 |
| `POST /v1/wechat/sendfile` | 发送文件 |
| `POST /v1/wechat/sendurlcard` | 发送 URL 卡片 |
| `POST /v1/wechat/getallmessage` | 获取当前窗口消息 |
| `POST /v1/wechat/gethistorymessage` | 获取历史消息 |
| `POST /v1/wechat/getnextnewmessage` | 获取新消息 |
| `POST /v1/wechat/getsession` | 获取会话列表 |
| `POST /v1/wechat/getsubwindow` | 获取指定子窗口 |
| `POST /v1/wechat/getallsubwindow` | 获取所有子窗口 |
| `POST /v1/wechat/chatwith` | 切换聊天窗口 |
| `POST /v1/wechat/getfriends` | 获取好友列表 |
| `POST /v1/wechat/getmyinfo` | 获取我的信息 |
| `POST /v1/wechat/getrecentgroups` | 获取群聊列表 |
| `POST /v1/wechat/switch/chat` | 切换到聊天页面 |
| `POST /v1/wechat/switch/contact` | 切换到联系人页面 |
| `POST /v1/wechat/isonline` | 检查在线状态 |

### 聊天接口（子窗口）

| 接口 | 说明 |
|------|------|
| `POST /v1/chat/send` | 子窗口发送消息 |
| `POST /v1/chat/getallmessage` | 获取子窗口所有消息 |
| `POST /v1/chat/getnewmessage` | 获取子窗口新消息 |
| `POST /v1/chat/msg/quote` | 发送引用消息 |
| `POST /v1/chat/close` | 关闭子窗口 |

## 直接 API 调用（备选）

如需直接调用 HTTP API，用 Python（不要用 PowerShell，有中文编码问题）：

```python
import requests

headers = {"Authorization": "Bearer token", "Content-Type": "application/json"}
body = {"who": "好友名", "msg": "消息内容"}
resp = requests.post("http://localhost:8000/v1/wechat/send", headers=headers, json=body)
print(resp.json())
```

## 响应格式

所有 API 返回统一格式：
```json
{
  "success": true,
  "message": "操作成功",
  "data": { ... }
}
```

## 注意事项

1. 微信客户端需要保持打开状态
2. wxautox4 需要激活后才能使用
3. **不要用 PowerShell 直接调用 API**（中文编码问题），请使用 Python 脚本
4. 修改 `config.yaml` 中的 `auth.token` 以增强安全性
