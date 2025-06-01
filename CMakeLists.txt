# ─────────────────────────────────────────────────────────────────────────────
# 1. 编辑区：把下面的路径改成你本地的实际位置
# ─────────────────────────────────────────────────────────────────────────────

# 1.1 TI MSPM SDK 根目录，示例：F:/TI/mspm0_sdk_2_01_00_03
set(SDK_DIR "F:/TI/mspm0_sdk_2_01_00_03")

# 1.2 syscfg.bat 的完整路径。如果放在工程子目录下，可以用相对路径：
#     示例：${CMAKE_SOURCE_DIR}/tools/keil/syscfg.bat
set(SYSCFG_SCRIPT "${CMAKE_SOURCE_DIR}/tools/keil/syscfg.bat")

# 1.3 要使用的 .syscfg 文件名称（只写文件名，不要带路径），示例：empty.syscfg
set(SYSCFG_FILE "empty.syscfg")

# 1.4 项目源码所在目录，一般是 Core 目录。如果你的工程结构不一样，请改成对应路径：
#     示例：${CMAKE_SOURCE_DIR}/Core
set(PROJ_DIR "${CMAKE_SOURCE_DIR}/Core")
# CMake最低版本
cmake_minimum_required(VERSION 3.20)

# 项目名称
set(PROJECT_NAME "empty")

# 链接脚本路径
set(LINKER_SCRIPT "../mspm0g3507.lds")

# 构建类型
set(CMAKE_BUILD_TYPE Debug)

# GLOB收集源文件
file (GLOB PROJECT_SOURCES
		Core/*.c
		Driver/ti/driverlib/*.c
		Driver/ti/driverlib/m0p/*.c
		Driver/ti/driverlib/m0p/sysctl/*.c
		BSP/Src/*.c
)

# 定义宏
set(PROJECT_DEFINES
		__MSPM0G3507__
)

# 包含目录
set(PROJECT_INCLUDES
		Core
		Driver/CMSIS/Core/Include
		Driver
		BSP/Inc
)

# 编译器和工具链配置
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_ID GNU)
set(CMAKE_CXX_COMPILER_ID GNU)

set(TOOLCHAIN_PREFIX arm-none-eabi-)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_LINKER ${TOOLCHAIN_PREFIX}ld)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)

# 项目定义
project(${PROJECT_NAME} C ASM)

# 添加可执行目标
add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})

# 编译器宏定义和包含路径
add_compile_definitions(${PROJECT_DEFINES})
include_directories(${PROJECT_INCLUDES})

# 设置文件后缀
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")

# C 编译器选项
if(${CMAKE_BUILD_TYPE} STREQUAL Debug)
	set(CMAKE_C_FLAGS "-mcpu=cortex-m0plus -std=gnu11 -mfloat-abi=soft --specs=nano.specs -mthumb -Wall -Og -g3 -ggdb -ffunction-sections -fdata-sections -fstack-usage -gstrict-dwarf")
elseif(${CMAKE_BUILD_TYPE} STREQUAL Release)
	set(CMAKE_C_FLAGS "-mcpu=cortex-m0plus -std=gnu11 -mfloat-abi=soft --specs=nano.specs -mthumb -Wall -Ofast -ffunction-sections -fdata-sections -fstack-usage -gstrict-dwarf")
endif()

# 汇编选项
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp")

# 链接器选项
set(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -T${LINKER_SCRIPT} --specs=nosys.specs -mthumb -static -lgcc -Wl,-Map=${PROJECT_NAME}.map -Wl,--gc-sections -Wl,--start-group -lc -lm -Wl,--end-group -Wl,--print-memory-usage")

# 构建后命令：输出大小、HEX 和 BIN 文件
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
		COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
		COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
		COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
)

# --- SysConfig 生成 ----------------------------------------------------------
# ─────────────────────────────────────────────────────────────────────────────
# 2. 自动校验：如果填写有误，会在配置阶段就报错，避免后面找不到路径
# ─────────────────────────────────────────────────────────────────────────────

if(NOT EXISTS "${SDK_DIR}")
	message(FATAL_ERROR "错误：找不到 SDK_DIR: ${SDK_DIR}\n请检查你的 SDK_DIR 路径是否正确。")
endif()

if(NOT EXISTS "${SYSCFG_SCRIPT}")
	message(FATAL_ERROR "错误：找不到 SYSCFG_SCRIPT: ${SYSCFG_SCRIPT}\n请检查你的 syscfg.bat 路径是否正确。")
endif()

if(NOT EXISTS "${PROJ_DIR}")
	message(FATAL_ERROR "错误：找不到 PROJ_DIR: ${PROJ_DIR}\n请检查你的 Core 目录路径是否正确。")
endif()

# ─────────────────────────────────────────────────────────────────────────────
# 3. 自定义 Target：在编译前先运行 syscfg.bat，生成 ti_msp_dl_config.c
# ─────────────────────────────────────────────────────────────────────────────

# run_syscfg 目标会在 “make/MyProject” 之前强制执行
add_custom_target(run_syscfg ALL
		COMMAND "${SYSCFG_SCRIPT}" "${PROJ_DIR}" "${SYSCFG_FILE}" "${SDK_DIR}"
		WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
		COMMENT "正在运行 syscfg.bat 以生成 ti_msp_dl_config.c..."
)


add_dependencies(${PROJECT_NAME} run_syscfg)
# ---------------------------------------------------------------------------
#cmd.exe /C "$P../tools/keil/syscfg.bat '$P' empty.syscfg F:\TI\mspm0_sdk_2_01_00_03"
# 参考：
# C:\ti\mspm0_sdk_2_01_00_03\examples\nortos\LP_MSPM0L1306\driverlib\empty\gcc\makefile
# STM32CubeMX 生成的 CMakeLists.txt
