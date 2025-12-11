# ECH Workers for OpenWrt

从源码编译 ECH Workers 代理客户端。

## 简介

ECH (Encrypted Client Hello) Workers 是一个基于 TLS 1.3 ECH 技术的代理客户端，支持：

- SOCKS5 和 HTTP CONNECT 代理协议
- 智能分流（全局代理、跳过中国大陆、直连）
- IPv4/IPv6 双栈支持

## 编译

```bash
# 选择包
make menuconfig
# Network -> Web Servers/Proxies -> ech-workers

# 编译
make package/ech-workers/compile V=s
```

## 依赖

- golang/host（编译时依赖）
- ca-bundle（运行时依赖）

## 使用

```bash
# 基本用法
ech-workers -f your-worker.workers.dev:443 -l 127.0.0.1:30001

# 跳过中国大陆
ech-workers -f your-worker.workers.dev:443 -l 127.0.0.1:30001 -routing bypass_cn

# 完整参数
ech-workers \
  -f your-worker.workers.dev:443 \
  -l 0.0.0.0:30001 \
  -token your-token \
  -ip saas.sin.fan \
  -dns dns.alidns.com/dns-query \
  -ech cloudflare-ech.com \
  -routing bypass_cn
```

## 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `-f` | (必需) | 服务器地址 |
| `-l` | 127.0.0.1:30000 | 监听地址 |
| `-token` | (空) | 身份令牌 |
| `-ip` | (空) | 优选 IP |
| `-dns` | dns.alidns.com/dns-query | DoH 服务器 |
| `-ech` | cloudflare-ech.com | ECH 域名 |
| `-routing` | global | 分流模式 |

## 分流模式

- `global` - 全局代理
- `bypass_cn` - 跳过中国大陆（自动下载 IP 列表）
- `none` - 直连模式

## 配合 LuCI 使用

安装 `luci-app-echworkers` 可获得 Web 管理界面。

## 上游项目

- [byJoey/ech-wk](https://github.com/byJoey/ech-wk)

## 许可证

MIT License
