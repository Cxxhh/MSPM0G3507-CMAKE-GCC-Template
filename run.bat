@echo off
setlocal enabledelayedexpansion

echo 配置
if not exist build (
    mkdir build
)
cd build

if not exist build.ninja (
    cmake -DCMAKE_BUILD_TYPE=Debug ^
          -DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE ^
          -S .. ^
          -B . ^
          -G Ninja
)

echo 编译
cmake --build . -- -j16

:: 修复 compile_commands.json 路径格式（适用于 clangd）
if exist compile_commands.json (
    echo 修正路径
    powershell -NoLogo -NoProfile -Command ^
    "Get-Content compile_commands.json | ForEach-Object { $_ -replace '/([a-z])/', ([regex]::Match($_, '/([a-z])/').Groups[1].Value.ToUpper() + ':/') } | Set-Content compile_temp.json; Move-Item -Force compile_temp.json compile_commands.json"
)

:: 查找 .elf 文件
set "elf_file="
for %%f in (*.elf) do (
    set "elf_file=%%f"
    goto found
)
:found

if not defined elf_file (
    echo 错误：未找到 ELF
    exit /b 1
)

set "bin_file=%elf_file:.elf=.bin%"
set "hex_file=%elf_file:.elf=.hex%"

echo 生成文件
arm-none-eabi-objcopy -O binary "%elf_file%" "%bin_file%"
arm-none-eabi-objcopy -O ihex "%elf_file%" "%hex_file%"
arm-none-eabi-size "%elf_file%"

echo 烧录
probe-rs download --chip MSPM0G3507 "%elf_file%"

echo 复位
probe-rs reset --chip MSPM0G3507
