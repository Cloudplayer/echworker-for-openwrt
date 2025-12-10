# LuCI App for ECH Workers

LuCI 界面支持 ECH (Encrypted Client Hello) Workers 代理客户端。

## 功能特性

- ✅ ECH 加密 - 基于 TLS 1.3 ECH 技术，加密 SNI 信息
- ✅ 多协议支持 - 同时支持 SOCKS5 和 HTTP CONNECT 代理协议
- ✅ **透明代理** - 内置 TPROXY 支持，LAN 设备无需任何配置即可翻墙
- ✅ 智能分流 - 三种分流模式：全局代理、跳过中国大陆、直连模式
- ✅ IPv4/IPv6 双栈 - 完整支持 IPv4 和 IPv6 地址的分流判断
- ✅ Web 界面管理 - 通过 LuCI 界面配置和管理
- ✅ **独立运行** - 无需 PassWall、OpenClash 等其他插件配合

## 依赖

本包会自动依赖并安装 `ech-workers` 二进制程序，无需手动下载。

安装 `luci-app-echworkers` 时会自动从源码编译并安装 `ech-workers`。

## 配置说明

### 基本设置

- **启用**: 启用/禁用服务
- **服务器地址**: ECH Workers 服务器地址，格式 `domain:port`
- **监听地址**: 本地监听地址，默认 `127.0.0.1:30001`
- **分流模式**: 
  - 全局代理：所有流量走代理
  - 跳过中国大陆：中国网站直连，其他走代理（自动下载 IP 列表）
  - 直连模式：不设置代理

### 透明代理设置

- **启用透明代理**: 开启后 LAN 设备无需配置代理即可翻墙
- **TPROXY 端口**: 透明代理监听端口，默认 12345

> 💡 **透明代理原理**: 通过 nftables 将 LAN 设备的 HTTP/HTTPS 流量重定向到 TPROXY 端口，程序自动获取原始目标地址并代理。

### 高级设置

- **令牌**: 身份验证令牌（可选）
- **优选 IP**: 指定服务器 IP，绕过 DNS 解析
- **DoH 服务器**: DNS over HTTPS 服务器，用于 ECH 查询
- **ECH 域名**: ECH 配置域名

## 使用方法

### 1. 配置服务器

在 LuCI 界面中填写服务器地址和其他参数。

### 2. 启动服务

勾选"启用"并保存应用配置，服务会自动启动。

### 3. 选择使用方式

#### 方式一：透明代理（推荐）

1. 在 LuCI 界面启用"透明代理"
2. 保存并应用
3. **完成！** LAN 下所有设备自动翻墙，无需任何客户端配置

> ⚠️ **注意**: 透明代理目前仅支持 IPv4，IPv6 流量会被阻止以强制回退到 IPv4。

#### 方式二：手动配置代理

将设备或应用的代理设置为：
- 代理类型: SOCKS5 或 HTTP
- 代理地址: 路由器 IP
- 代理端口: 30001（或你配置的端口）

### 4. 与其他插件集成（可选）

如果你已有 PassWall/OpenClash 等插件，也可以将 ECH Workers 作为上游代理：

#### PassWall

1. 进入 PassWall → 节点管理
2. 添加节点 → SOCKS
3. 填写：
   - 地址: 127.0.0.1
   - 端口: 30001

#### OpenClash

1. 在配置文件中添加 proxy：

```yaml
proxies:
  - name: "ECH-Workers"
    type: socks5
    server: 127.0.0.1
    port: 30001
```

## 命令行管理

```bash
# 启动服务
/etc/init.d/echworkers start

# 停止服务
/etc/init.d/echworkers stop

# 重启服务
/etc/init.d/echworkers restart

# 查看状态
/etc/init.d/echworkers status

# 开机自启
/etc/init.d/echworkers enable

# 禁用自启
/etc/init.d/echworkers disable

# 查看日志
logread | grep echworkers
```

## 配置文件

UCI 配置文件位于 `/etc/config/echworkers`：

```
config echworkers 'config'
	option enabled '0'
	option server 'your-worker.workers.dev:443'
	option listen '127.0.0.1:30001'
	option token ''
	option ip ''
	option dns 'dns.alidns.com/dns-query'
	option ech 'cloudflare-ech.com'
	option routing 'bypass_cn'
	option transparent '0'
	option tproxy_port '12345'
```

## 故障排除

### 服务无法启动

1. 检查 ech-workers 是否已安装：

```bash
which ech-workers
```

2. 查看日志：
```bash
logread | grep echworkers
```

### 透明代理不工作

1. 检查 nftables 规则是否生效：

```bash
nft list table inet echworkers
```

2. 检查 TPROXY 端口是否监听：

```bash
netstat -tlnp | grep 12345
```

3. 查看 TPROXY 日志：

```bash
logread | grep TPROXY
```

4. 如果 IPv6 设备无法访问，这是正常的。透明代理目前仅支持 IPv4，IPv6 流量会被阻止以强制客户端回退到 IPv4。

### IP 列表下载失败

使用 `bypass_cn` 模式时，程序会自动下载中国 IP 列表。如果下载失败：

1. 检查网络连接
2. 手动下载 IP 列表：

```bash
# IPv4
wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt -O /tmp/chn_ip.txt

# IPv6
wget https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt -O /tmp/chn_ip_v6.txt
```

## 许可证

MIT License

## 相关链接

- [ECH Workers 项目](https://github.com/ntbowen/ech-wk)
- [OpenWrt LuCI](https://github.com/openwrt/luci)
