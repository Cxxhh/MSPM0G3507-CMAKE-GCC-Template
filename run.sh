#!/bin/bash
set -e
set -u

# ===== 配色输出 =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 开始构建工程（增量编译）...${NC}"

# ===== 创建并进入 build 目录 =====
mkdir -p build
cd build

echo -e "${GREEN}⚙️  运行 SysConfig 配置生成器...${NC}"

# 设置路径（注意这里路径都以 run.sh 所在目录为基础）

# ===== 仅首次或缺失时运行 CMake 配置 =====
if [ ! -f "build.ninja" ]; then
    echo -e "${GREEN}🚀 生成构建文件...${NC}"
    cmake -DCMAKE_BUILD_TYPE=Debug \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE \
          -S .. \
          -B . \
          -G Ninja
else
    echo -e "${GREEN}📦 已存在构建文件，跳过 CMake 配置${NC}"
fi

# ===== 编译工程（增量）=====
echo -e "${GREEN}⚙️  编译中（仅编译改动源文件）...${NC}"
cmake --build . -- -j16

# ===== 修复 compile_commands.json 中的路径格式（可选）=====
if [ -f compile_commands.json ]; then
    sed -i "s|/a/|A:/|g; s|/b/|B:/|g; s|/c/|C:/|g; s|/d/|D:/|g; s|/e/|E:/|g; s|/f/|F:/|g; s|/g/|G:/|g; s|/h/|H:/|g; s|/i/|I:/|g; s|/j/|J:/|g; s|/k/|K:/|g; s|/l/|L:/|g; s|/m/|M:/|g; s|/n/|N:/|g; s|/o/|O:/|g; s|/p/|P:/|g; s|/q/|Q:/|g; s|/r/|R:/|g; s|/s/|S:/|g; s|/t/|T:/|g; s|/u/|U:/|g; s|/v/|V:/|g; s|/w/|W:/|g; s|/x/|X:/|g; s|/y/|Y:/|g; s|/z/|Z:/|g" compile_commands.json
fi

# ===== 查找 ELF 文件 =====
elf_file=$(find . -maxdepth 1 -name "*.elf" | head -n 1)

if [ -z "$elf_file" ]; then
    echo -e "${RED}❌ Error: 没有找到 ELF 文件！${NC}"
    exit 1
fi

bin_file="${elf_file%.elf}.bin"
hex_file="${elf_file%.elf}.hex"

# ===== 生成 BIN / HEX 文件 ===== 
echo -e "${GREEN}📦 正在生成 $bin_file 和 $hex_file...${NC}"
arm-none-eabi-objcopy -O binary "$elf_file" "$bin_file"
arm-none-eabi-objcopy -O ihex "$elf_file" "$hex_file"
  
arm-none-eabi-size "$elf_file"

echo -e "${GREEN}📄 Binary 文件信息:${NC}"
file "$bin_file"

echo -e "${GREEN}✅ 构建完成！${NC}"

# ===== 烧录（使用 probe-rs）=====
echo -e "${GREEN}🚀 烧录: $elf_file${NC}"
probe-rs download --chip MSPM0G3507 "$elf_file"

echo -e "${GREEN}🔁 复位${NC}"
probe-rs reset --chip MSPM0G3507
