# 快速开始指南

## 5 分钟快速部署

### 步骤 1: 检查项目

```bash
cd /home/zag/OpenWrt/package/Applications/Zag/luci-app-echworkers
./check.sh
```

### 步骤 2: 编译包

```bash
./build.sh
```

或手动编译：

```bash
cd /home/zag/OpenWrt
make package/luci-app-echworkers/compile V=s
```

### 步骤 3: 查找生成的包

```bash
find bin/packages -name "luci-app-echworkers*.ipk"
find bin/packages -name "luci-i18n-echworkers-zh-cn*.ipk"
```

### 步骤 4: 上传到路由器

```bash
# 替换为你的路由器 IP
ROUTER_IP="192.168.1.1"

scp bin/packages/*/luci/luci-app-echworkers*.ipk root@${ROUTER_IP}:/tmp/
scp bin/packages/*/luci/luci-i18n-echworkers-zh-cn*.ipk root@${ROUTER_IP}:/tmp/
```

### 步骤 5: 安装包

```bash
ssh root@${ROUTER_IP}

# 安装主包
opkg install /tmp/luci-app-echworkers*.ipk

# 安装中文语言包
opkg install /tmp/luci-i18n-echworkers-zh-cn*.ipk

# 清除 LuCI 缓存
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

### 步骤 6: 配置服务

> **注意**: `ech-workers` 二进制已经通过依赖自动安装，无需手动下载！

访问 LuCI 界面：`http://192.168.1.1` → 服务 → ECH Workers

配置项：
- **启用**: ✓
- **服务器地址**: `your-worker.workers.dev:443`
- **监听地址**: `127.0.0.1:30001`
- **分流模式**: 跳过中国大陆

保存并应用。

### 步骤 7: 验证运行

```bash
# 检查服务状态
/etc/init.d/echworkers status

# 查看日志
logread | grep echworkers

# 测试连接
curl --socks5 127.0.0.1:30001 https://www.google.com
```

## 一键安装脚本

保存为 `install-echworkers.sh` 并在路由器上执行：

```bash
#!/bin/sh
# ECH Workers 一键安装脚本

set -e

echo "========================================="
echo "ECH Workers 一键安装"
echo "========================================="

# 1. 检测架构
ARCH=$(uname -m)
VERSION="v1.3"

case "$ARCH" in
    x86_64) BINARY="ech-workers-linux-amd64" ;;
    aarch64) BINARY="ech-workers-linux-arm64" ;;
    armv7l) BINARY="ech-workers-linux-armv7" ;;
    mips*) BINARY="ech-workers-linux-mipsle" ;;
    *)
        echo "错误: 不支持的架构 $ARCH"
        exit 1
        ;;
esac

echo "检测到架构: $ARCH"
echo "将下载: $BINARY"
echo ""

# 2. 下载二进制
echo "正在下载 ech-workers..."
wget "https://github.com/ntbowen/ech-wk/releases/download/$VERSION/$BINARY" \
    -O /usr/bin/ech-workers || {
    echo "错误: 下载失败"
    exit 1
}

chmod +x /usr/bin/ech-workers
echo "✓ ech-workers 安装成功"
echo ""

# 3. 验证安装
echo "验证安装..."
/usr/bin/ech-workers -h > /dev/null 2>&1 && {
    echo "✓ ech-workers 可以正常运行"
} || {
    echo "警告: ech-workers 可能无法运行"
}
echo ""

# 4. 检查 LuCI 应用
if [ -f "/etc/config/echworkers" ]; then
    echo "✓ 检测到 luci-app-echworkers"
    echo ""
    echo "配置文件: /etc/config/echworkers"
    echo "管理界面: LuCI → 服务 → ECH Workers"
else
    echo "! 未检测到 luci-app-echworkers"
    echo "请先安装 luci-app-echworkers 包"
fi

echo ""
echo "========================================="
echo "安装完成！"
echo "========================================="
echo ""
echo "下一步:"
echo "  1. 访问 LuCI 界面配置服务器"
echo "  2. 或手动编辑: vi /etc/config/echworkers"
echo "  3. 启动服务: /etc/init.d/echworkers start"
echo ""
```

## 常见问题快速解决

### 问题 1: 菜单不显示

```bash
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
# 清除浏览器缓存并刷新
```

### 问题 2: 服务启动失败

```bash
# 检查二进制
which ech-workers
ls -l /usr/bin/ech-workers

# 查看日志
logread | grep echworkers

# 手动测试
/usr/bin/ech-workers -f test.workers.dev:443 -l 127.0.0.1:30001
```

### 问题 3: 中文未显示

```bash
# 确认语言包已安装
opkg list-installed | grep echworkers

# 重新安装语言包
opkg install /tmp/luci-i18n-echworkers-zh-cn*.ipk --force-reinstall
```

### 问题 4: 配置不生效

```bash
# 查看 UCI 配置
uci show echworkers

# 重启服务
/etc/init.d/echworkers restart

# 查看进程
ps | grep ech-workers
```

## 卸载

```bash
# 停止服务
/etc/init.d/echworkers stop
/etc/init.d/echworkers disable

# 卸载包
opkg remove luci-app-echworkers luci-i18n-echworkers-zh-cn

# 删除配置（可选）
rm /etc/config/echworkers

# 删除二进制（可选）
rm /usr/bin/ech-workers
```

## 下一步

- 查看 [README.md](README.md) 了解详细功能
- 查看 [INSTALL.md](INSTALL.md) 了解完整安装步骤
- 查看 [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) 了解项目架构
