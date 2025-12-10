#!/bin/bash
# 项目完整性检查脚本

echo "========================================="
echo "luci-app-echworkers 项目检查"
echo "========================================="
echo ""

PACKAGE_DIR="/home/zag/OpenWrt/package/Applications/Zag/luci-app-echworkers"
cd "$PACKAGE_DIR"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (缺失)"
        return 1
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 (可执行)"
        return 0
    else
        echo -e "${YELLOW}!${NC} $1 (无执行权限)"
        chmod +x "$1" 2>/dev/null && echo -e "  ${GREEN}→${NC} 已修复" || echo -e "  ${RED}→${NC} 修复失败"
        return 1
    fi
}

echo "1. 核心文件检查"
echo "-------------------"
check_file "Makefile"
check_file "README.md"
check_file "INSTALL.md"
check_file "PROJECT_SUMMARY.md"
echo ""

echo "2. 前端文件检查"
echo "-------------------"
check_file "htdocs/luci-static/resources/view/echworkers/echworkers.js"
echo ""

echo "3. 配置文件检查"
echo "-------------------"
check_file "root/etc/config/echworkers"
check_file "root/usr/share/luci/menu.d/luci-app-echworkers.json"
check_file "root/usr/share/rpcd/acl.d/luci-app-echworkers.json"
echo ""

echo "4. Init 脚本检查"
echo "-------------------"
check_executable "root/etc/init.d/echworkers"
check_executable "build.sh"
echo ""

echo "5. 翻译文件检查"
echo "-------------------"
check_file "po/zh_Hans/echworkers.po"
check_file "po/templates/echworkers.pot"
echo ""

echo "6. 语法检查"
echo "-------------------"

# 检查 JSON 语法
echo -n "检查 menu.d JSON... "
if python3 -m json.tool root/usr/share/luci/menu.d/luci-app-echworkers.json > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ 语法错误${NC}"
fi

echo -n "检查 acl.d JSON... "
if python3 -m json.tool root/usr/share/rpcd/acl.d/luci-app-echworkers.json > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ 语法错误${NC}"
fi

# 检查 JavaScript 语法（如果有 node）
if command -v node &> /dev/null; then
    echo -n "检查 JavaScript 语法... "
    if node -c htdocs/luci-static/resources/view/echworkers/echworkers.js 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ 语法错误${NC}"
    fi
fi

# 检查 Shell 脚本语法
echo -n "检查 init 脚本语法... "
if bash -n root/etc/init.d/echworkers 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ 语法错误${NC}"
fi

echo ""
echo "7. 统计信息"
echo "-------------------"
echo "JavaScript 行数: $(wc -l < htdocs/luci-static/resources/view/echworkers/echworkers.js)"
echo "Init 脚本行数: $(wc -l < root/etc/init.d/echworkers)"
echo "翻译条目数: $(grep -c '^msgid' po/zh_Hans/echworkers.po)"
echo ""

echo "========================================="
echo "检查完成！"
echo "========================================="
echo ""
echo "下一步:"
echo "  1. 编译: ./build.sh"
echo "  2. 或手动: cd ../../../.. && make package/luci-app-echworkers/compile V=s"
echo ""
