@ech, off
setlocal enabledelayedexpansion

echo [?] ��ʼ�������̣��������룩...

:: ���������� build Ŀ¼
if not exist build (
    mkdir build
)
cd build

:: ��� build.ninja �Ƿ����
if not exist build.ninja (
    echo [?] ���ɹ����ļ�...
    cmake -DCMAKE_BUILD_TYPE=Debug ^
          -DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE ^
          -S .. ^
          -B . ^
          -G Ninja
) else (
    echo [?] �Ѵ��ڹ����ļ������� CMake ����
)

:: ������Ŀ
echo [?? ] �����У�������Ķ�Դ�ļ���...
cmake --build . -- -j16

:: �޸� compile_commands.json ��·����ʽ������ clangd��
if exist compile_commands.json (
    echo %GREEN%[INFO] Fixing paths in compile_commands.json...%RESET%
    powershell -NoLogo -NoProfile -Command ^
    "Get-Content compile_commands.json | ForEach-Object { $_ -replace '/([a-z])/', ([regex]::Match($_, '/([a-z])/').Groups[1].Value.ToUpper() + ':/') } | Set-Content compile_temp.json; Move-Item -Force compile_temp.json compile_commands.json"
)

:: ���� .elf �ļ���ֻȡ��һ����
set "elf_file="
for %%f in (*.elf) do (
    set "elf_file=%%f"
    goto :found
)
:found

if not defined elf_file (
    echo [?] Error: û���ҵ� ELF �ļ���
    exit /b 1
)

set "bin_file=%elf_file:.elf=.bin%"
set "hex_file=%elf_file:.elf=.hex%"

:: ���� bin / hex �ļ�
echo [?] �������� %bin_file% �� %hex_file%...
arm-none-eabi-objcopy -O binary "%elf_file%" "%bin_file%"
arm-none-eabi-objcopy -O ihex "%elf_file%" "%hex_file%"

arm-none-eabi-size "%elf_file%"
echo [?] Binary �ļ���Ϣ:
file "%bin_file%"

echo [?] ������ɣ�

:: ��¼�븴λ
echo [?] ��¼: %elf_file%
probe-rs download --chip MSPM0G3507 "%elf_file%"

echo [?] ��λ
probe-rs reset --chip MSPM0G3507
