@echo off
setlocal enabledelayedexpansion

echo ����
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

echo ����
cmake --build . -- -j16

:: �޸� compile_commands.json ·����ʽ�������� clangd��
if exist compile_commands.json (
    echo ����·��
    powershell -NoLogo -NoProfile -Command ^
    "Get-Content compile_commands.json | ForEach-Object { $_ -replace '/([a-z])/', ([regex]::Match($_, '/([a-z])/').Groups[1].Value.ToUpper() + ':/') } | Set-Content compile_temp.json; Move-Item -Force compile_temp.json compile_commands.json"
)

:: ���� .elf �ļ�
set "elf_file="
for %%f in (*.elf) do (
    set "elf_file=%%f"
    goto found
)
:found

if not defined elf_file (
    echo ����δ�ҵ� ELF
    exit /b 1
)

set "bin_file=%elf_file:.elf=.bin%"
set "hex_file=%elf_file:.elf=.hex%"

echo �����ļ�
arm-none-eabi-objcopy -O binary "%elf_file%" "%bin_file%"
arm-none-eabi-objcopy -O ihex "%elf_file%" "%hex_file%"
arm-none-eabi-size "%elf_file%"

echo ��¼
probe-rs download --chip MSPM0G3507 "%elf_file%"

echo ��λ
probe-rs reset --chip MSPM0G3507
