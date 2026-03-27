---
name: wxauto
description: "微信自动化操作。通过 wxautox4 RESTful API 实现发送消息、获取聊天记录、监听消息、好友管理等功能。Use when: (1) 发送微信消息给好友或群聊，(2) 读取微信聊天记录，(3) 监听新消息，(4) 获取好友列表或群聊列表，(5) 接受好友申请，(6) 切换聊天窗口等微信操作。"

---

# 微信自动化

通过 wxautox4 RESTful API 操作微信，支持消息收发、监听、好友管理等功能。API 服务必须运行在 **Windows 设备**上（wxautox4 仅支持 Windows），可通过本地或远程方式连接。

## 步骤 0：平台检测（最优先执行）

**在做任何其他操作之前，先检测当前设备的操作系统**：

```python
import platform
print(platform.system())  # 返回 'Windows' / 'Darwin' / 'Linux'
```

根据结果走不同分支：

---

### 非 Windows 设备（macOS / Linux）

> wxautox4 服务只能运行在 Windows 上，**不要尝试在当前设备安装或启动服务**。

直接询问用户远程服务信息（使用 AskUserQuestion 或等效工具）：

```
问题1：请提供 wxauto-restful-api 服务地址（例如 http://192.168.1.100:8000）
问题2：请提供服务的 Bearer Token（见服务端 config.yaml 的 auth.token，默认为 token）
```

获取到地址和 token 后：
1. 将配置写入环境变量或直接传入脚本参数
2. 调用健康检查接口验证连通性：`GET /v1/wechat/status`
3. 如果连接失败，提示用户检查：网络是否可达、服务是否已启动、token 是否正确
4. 连接成功后直接执行用户操作，**不需要任何本地安装步骤**

---

### Windows 设备

先检查本地服务是否已运行（读取 `~/.wxautox/service_status.json` 并做健康检查）：

- **本地服务已运行**：自动连接，无需用户操作
- **本地服务未运行**：询问用户选择方式（见下方「服务未运行时的处理」）

---

## 服务配置

- 认证：Bearer Token（见 `config.yaml` 的 `auth.token`，默认值为 `token`）
- 服务状态文件：`~/.wxautox/service_status.json`（服务启动时自动生成，仅 Windows 本地部署时存在）

### 配置优先级（从高到低）

1. **命令行参数**
   ```bash
   python scripts/wxapi.py --base-url "http://192.168.1.100:8000" --token "my-token" send "好友" "消息"
   ```

2. **环境变量**
   ```bash
   # 通用（macOS/Linux/Windows）
   export WXAPI_BASE_URL="http://192.168.1.100:8000"
   export WXAPI_TOKEN="my-token"

   # Windows PowerShell
   $env:WXAPI_BASE_URL = "http://192.168.1.100:8000"
   $env:WXAPI_TOKEN = "my-token"
   ```

3. **service_status.json** - 自动检测（仅 Windows 本地部署时可用）

4. **config.yaml** - 服务目录下的配置文件（仅 Windows 本地部署时可用）

5. **默认值** - `http://localhost:8000`, token 为 `token`

### 服务目录搜索顺序（仅 Windows）

1. `WXAPI_SERVICE_DIR` 环境变量指定的路径
2. `~/.wxautox/service_status.json` 中记录的 `service_dir`
3. `../wxauto-restful-api`（相对于 skill 目录）
4. `~/wxauto-restful-api`

## 启动服务（仅 Windows）

> macOS / Linux 用户无需执行此节，直接使用远程服务地址即可。

**前置要求**：

1. 安装 wxautox4：
   ```powershell
   pip install wxautox4
   ```
   > 需 Windows 系统，Python 3.9–3.12 64 位

2. 激活 wxautox4：
   ```powershell
   wxautox4 -a your-activation-code
   ```
   > 获取激活码：https://docs.wxauto.org/plus

3. 部署并启动 API 服务：
   ```powershell
   # 进入服务目录
   cd C:\path\to\wxauto-restful-api
   # 启动服务
   python run.py
   ```

   或后台启动：
   ```powershell
   Start-Process python -ArgumentList "run.py" -WorkingDirectory "C:\path\to\wxauto-restful-api" -WindowStyle Hidden
   ```

## 脚本路径

调用脚本使用相对于 skill 目录根的相对路径：

```bash
python scripts/wxapi.py send "好友" "消息"
```

查看帮助：
```bash
python scripts/wxapi.py --help
```

## 可用命令

### 初始化和状态

```powershell
# 初始化微信实例
python scripts/wxapi.py init

# 获取服务状态
python scripts/wxapi.py status

# 检查是否在线
python scripts/wxapi.py online

# 获取我的信息
python scripts/wxapi.py myinfo
```

### 发送消息

```powershell
# 主窗口发送
python scripts/wxapi.py send "好友名" "消息内容"

# 精确匹配
python scripts/wxapi.py send "好友名" "消息内容" --exact

# @群成员
python scripts/wxapi.py send "群名" "开会了" --at "张三,李四"

# 子窗口发送
python scripts/wxapi.py send-chat "好友名" "消息内容"
```

### 读取消息

```powershell
# 获取聊天记录（主窗口）
python scripts/wxapi.py getmsg "好友名"

# 获取聊天记录（子窗口）
python scripts/wxapi.py getmsg-chat "好友名"

# 获取历史消息
python scripts/wxapi.py history "好友名" --count 100

# 获取新消息（主窗口轮询）
python scripts/wxapi.py newmsg

# 获取新消息（子窗口）
python scripts/wxapi.py newmsg-chat "好友名"
```

### 监听管理

```powershell
# 添加监听（打开子窗口）
python scripts/wxapi.py listen "好友名"
```

### 会话管理

```powershell
# 获取会话列表
python scripts/wxapi.py session

# 获取所有子窗口
python scripts/wxapi.py windows

# 切换聊天窗口
python scripts/wxapi.py chatwith "好友名" --exact
```

### 获取列表

```powershell
# 好友列表
python scripts/wxapi.py friends

# 群聊列表
python scripts/wxapi.py groups
```

### 页面控制

```powershell
# 切换到聊天页面
python scripts/wxapi.py switch-chat

# 切换到联系人页面
python scripts/wxapi.py switch-contact
```

### 查看帮助

```powershell
python scripts/wxapi.py --help
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

## 服务未运行时的处理

### 非 Windows 设备

无法在本地启动服务。**不要直接报错**，使用询问工具询问用户：

提问内容：「当前设备（macOS/Linux）无法运行 wxautox4 服务，请提供运行在 Windows 设备上的远程服务信息」

需要用户提供：
1. **服务地址**（如 `http://192.168.1.100:8000`）
2. **Bearer Token**（服务端 `config.yaml` 中 `auth.token` 的值，默认为 `token`）

获取后做连通性验证，成功则继续执行用户原本的操作。

---

### Windows 设备

当执行命令发现 wxauto-restful-api 服务未运行时，wxapi.py 会按以下顺序尝试自动恢复：

1. 检查 `~/.wxautox/service_status.json` 中的 `service_dir` 定位项目路径
2. 搜索默认路径（见上方搜索顺序）
3. 找到项目目录后自动启动服务

如果以上都无法定位到项目目录，**不要直接报错**，使用询问工具询问用户：

提问内容：「wxauto-restful-api 服务未运行，请选择处理方式」

选项：
1. **自动部署并启动本地服务** - 从 GitHub 克隆项目，安装依赖，启动服务（启动后路径自动记录到 `service_status.json`）
2. **仅启动本地服务** - 服务目录已存在，只需启动（需用户提供路径）
3. **连接远程服务** - 服务运行在其他 Windows 设备上，需提供服务地址和 Token
4. **跳过** - 用户自行处理

如果用户选择「自动部署并启动本地服务」，执行以下步骤：

```powershell
# 1. 克隆项目到用户目录
cd ~
git clone https://github.com/cluic/wxauto-restful-api.git

# 2. 创建虚拟环境
cd wxauto-restful-api
python -m venv .venv

# 3. 激活虚拟环境并安装依赖
.venv\Scripts\activate
pip install -r requirements.txt

# 4. 后台启动服务
python run.py
```

启动后验证服务是否正常运行（检查健康接口），然后继续执行用户原本的操作。

## 注意事项

1. 微信客户端需要在运行服务的 **Windows 设备**上保持打开状态
2. wxautox4 需要激活后才能使用（仅 Windows 端需要）
3. **不要用 PowerShell 直接调用 API**（中文编码问题），请使用 Python 脚本
4. 修改服务端 `config.yaml` 中的 `auth.token` 以增强安全性
5. **macOS / Linux 用户**：跳过所有本地安装步骤，仅需提供远程服务地址和 Token 即可使用全部功能
