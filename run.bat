@ech, off
setlocal enabledelayedexpansion

echo [?] 开始构建工程（增量编译）...

:: 创建并进入 build 目录
if not exist build (
    mkdir build
)
cd build

:: 检查 build.ninja 是否存在
if not exist build.ninja (
    echo [?] 生成构建文件...
    cmake -DCMAKE_BUILD_TYPE=Debug ^
          -DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE ^
          -S .. ^
          -B . ^
          -G Ninja
) else (
    echo [?] 已存在构建文件，跳过 CMake 配置
)

:: 编译项目
echo [?? ] 编译中（仅编译改动源文件）...
cmake --build . -- -j16

:: 修复 compile_commands.json 的路径格式（用于 clangd）
if exist compile_commands.json (
    echo %GREEN%[INFO] Fixing paths in compile_commands.json...%RESET%
    powershell -NoLogo -NoProfile -Command ^
    "Get-Content compile_commands.json | ForEach-Object { $_ -replace '/([a-z])/', ([regex]::Match($_, '/([a-z])/').Groups[1].Value.ToUpper() + ':/') } | Set-Content compile_temp.json; Move-Item -Force compile_temp.json compile_commands.json"
)

:: 查找 .elf 文件（只取第一个）
set "elf_file="
for %%f in (*.elf) do (
    set "elf_file=%%f"
    goto :found
)
:found

if not defined elf_file (
    echo [?] Error: 没有找到 ELF 文件！
    exit /b 1
)

set "bin_file=%elf_file:.elf=.bin%"
set "hex_file=%elf_file:.elf=.hex%"

:: 生成 bin / hex 文件
echo [?] 正在生成 %bin_file% 和 %hex_file%...
arm-none-eabi-objcopy -O binary "%elf_file%" "%bin_file%"
arm-none-eabi-objcopy -O ihex "%elf_file%" "%hex_file%"

arm-none-eabi-size "%elf_file%"
echo [?] Binary 文件信息:
file "%bin_file%"

echo [?] 构建完成！

:: 烧录与复位
echo [?] 烧录: %elf_file%
probe-rs download --chip MSPM0G3507 "%elf_file%"

echo [?] 复位
probe-rs reset --chip MSPM0G3507
