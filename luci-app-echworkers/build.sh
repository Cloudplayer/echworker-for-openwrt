#!/bin/bash
# 快速编译测试脚本

set -e

PACKAGE_NAME="luci-app-echworkers"
PACKAGE_PATH="package/Applications/Zag/${PACKAGE_NAME}"

echo "========================================="
echo "编译 ${PACKAGE_NAME}"
echo "========================================="

# 返回 OpenWrt 根目录
cd "$(dirname "$0")/../../../.."

# 检查是否在 OpenWrt 根目录
if [ ! -f "feeds.conf.default" ]; then
    echo "错误: 不在 OpenWrt 根目录"
    exit 1
fi

echo "1. 清理旧的编译文件..."
make package/${PACKAGE_NAME}/clean V=s

echo ""
echo "2. 编译包..."
make package/${PACKAGE_NAME}/compile V=s

echo ""
echo "3. 查找生成的 IPK 文件..."
find bin/packages -name "${PACKAGE_NAME}*.ipk" -o -name "luci-i18n-echworkers*.ipk"

echo ""
echo "========================================="
echo "编译完成！"
echo "========================================="
echo ""
echo "安装命令:"
echo "  scp bin/packages/*/luci/${PACKAGE_NAME}*.ipk root@192.168.1.1:/tmp/"
echo "  ssh root@192.168.1.1 'opkg install /tmp/${PACKAGE_NAME}*.ipk'"
echo ""
