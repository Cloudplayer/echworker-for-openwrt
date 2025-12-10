# 安装指南

## 编译安装

### 1. 添加到 OpenWrt 源码

将此包放置在 `package/Applications/Zag/luci-app-echworkers/` 目录。

### 2. 配置编译选项

```bash
make menuconfig
```

导航到：
```
LuCI -> 3. Applications -> luci-app-echworkers
```

选中 `<*>` 或 `<M>`。

### 3. 编译

```bash
# 编译单个包
make package/Applications/Zag/luci-app-echworkers/compile V=s

# 或编译所有包
make package/compile V=s
```

### 4. 查找生成的 IPK

```bash
find bin/packages -name "luci-app-echworkers*.ipk"
find bin/packages -name "luci-i18n-echworkers-zh-cn*.ipk"
```

## 安装到路由器

### 方法 1: 通过 SCP 上传

```bash
# 上传 IPK 包
scp bin/packages/*/luci/luci-app-echworkers*.ipk root@192.168.1.1:/tmp/
scp bin/packages/*/luci/luci-i18n-echworkers-zh-cn*.ipk root@192.168.1.1:/tmp/

# SSH 登录路由器
ssh root@192.168.1.1

# 安装
opkg install /tmp/luci-app-echworkers*.ipk
opkg install /tmp/luci-i18n-echworkers-zh-cn*.ipk
```

### 方法 2: 通过 LuCI 界面

1. 登录 LuCI 界面
2. 进入 System → Software
3. 点击 "Upload Package..."
4. 选择 IPK 文件并上传安装

## 安装 ech-workers 二进制

### 自动安装脚本

```bash
#!/bin/sh
# 自动检测架构并下载 ech-workers

ARCH=$(uname -m)
VERSION="v1.3"  # 修改为最新版本

case "$ARCH" in
    x86_64)
        BINARY="ech-workers-linux-amd64"
        ;;
    aarch64)
        BINARY="ech-workers-linux-arm64"
        ;;
    armv7l)
        BINARY="ech-workers-linux-armv7"
        ;;
    mips*)
        BINARY="ech-workers-linux-mipsle"
        ;;
    *)
        echo "不支持的架构: $ARCH"
        exit 1
        ;;
esac

echo "下载 $BINARY..."
wget "https://github.com/ntbowen/ech-wk/releases/download/$VERSION/$BINARY" -O /usr/bin/ech-workers

if [ $? -eq 0 ]; then
    chmod +x /usr/bin/ech-workers
    echo "安装成功！"
    /usr/bin/ech-workers -h
else
    echo "下载失败！"
    exit 1
fi
```

### 手动安装

```bash
# 1. 确定架构
uname -m

# 2. 下载对应版本
wget https://github.com/ntbowen/ech-wk/releases/download/v1.3/ech-workers-linux-<arch> -O /usr/bin/ech-workers

# 3. 添加执行权限
chmod +x /usr/bin/ech-workers

# 4. 验证安装
/usr/bin/ech-workers -h
```

## 验证安装

### 1. 检查服务

```bash
/etc/init.d/echworkers status
```

### 2. 检查 LuCI 菜单

访问 LuCI 界面，应该能在 "服务" 菜单下看到 "ECH Workers"。

### 3. 测试配置

```bash
# 编辑配置
uci set echworkers.config.enabled='1'
uci set echworkers.config.server='your-worker.workers.dev:443'
uci commit echworkers

# 启动服务
/etc/init.d/echworkers start

# 查看日志
logread | grep echworkers

# 测试连接
curl --socks5 127.0.0.1:30001 https://www.google.com
```

## 卸载

```bash
# 停止服务
/etc/init.d/echworkers stop
/etc/init.d/echworkers disable

# 卸载包
opkg remove luci-app-echworkers
opkg remove luci-i18n-echworkers-zh-cn

# 删除配置（可选）
rm /etc/config/echworkers

# 删除二进制（可选）
rm /usr/bin/ech-workers
```

## 常见问题

### Q: 编译时提示找不到 luci.mk

**A**: 确保已安装 LuCI feed：

```bash
./scripts/feeds update luci
./scripts/feeds install -a -p luci
```

### Q: 安装后菜单不显示

**A**: 清除浏览器缓存，或执行：

```bash
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

### Q: 服务启动失败

**A**: 检查：
1. ech-workers 是否已安装：`which ech-workers`
2. 是否有执行权限：`ls -l /usr/bin/ech-workers`
3. 配置是否正确：`uci show echworkers`
4. 查看详细日志：`logread -f`

### Q: 中文翻译未生效

**A**: 确保安装了中文语言包：

```bash
opkg install luci-i18n-echworkers-zh-cn
```

然后在 LuCI 界面切换语言为简体中文。
