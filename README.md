# MSPM0G3507-CMAKE-GCC-Template

这是一个适用于 [TI MSPM0G3507 微控制器](https://www.ti.com/product/MSPM0G3507) 的嵌入式项目模板，基于 **CMake** 构建系统、**ARM GCC** 工具链，使用 **Ninja** 加速构建流程，并集成 [Probe-rs](https://probe.rs/) 实现程序烧录与调试。

本模板适用于裸机（无 RTOS）开发，助力开发者快速构建高效、结构清晰的嵌入式工程。

> 💡 尚未配置开发环境？可参考：[cmake_ninja_clangd_stm32_dev_env 教程](https://github.com/linkyourbin/cmake_ninja_clangd_stm32_dev_env/blob/master/tut.md) 或者 [bilibili 视频教程](https://www.bilibili.com/video/BV11tj9zDEVa/?spm_id_from=333.1007.top_right_bar_window_history.content.click&vd_source=9e440f398c1d1374db8629d6beed4370)
> 🔄 需要适配其他 MSPM0 系列芯片？可基于本模板裁剪移植  
> 📌 本项目参考并整合以下优秀开源模板：
> - [MSPM0-CMAKE-GCC-Template](https://github.com/zhzhongshi/MSPM0-CMAKE-GCC-Template)
> - [cmake_ninja_clangd_stm32_dev_env](https://github.com/linkyourbin/cmake_ninja_clangd_stm32_dev_env)

---

## 🧱 项目结构

```
MSPM0-CMAKE-GCC-TEMPLATE/
├── .cache/                 # 构建缓存（自动生成）
├── .vscode/                # VS Code 配置（如 launch.json, settings.json 等）
├── BSP/                    # 板级支持包（Board Support Package）
├── Core/                   # 主应用代码（如 main.c）
├── Driver/                 # 驱动代码，包括 CMSIS 和 TI DriverLib
├── .clang-format           # Clang 格式化规则
├── .clangd                 # Clangd 智能提示配置
├── .gitignore              # Git 忽略规则
├── CMakeLists.txt          # 顶层 CMake 构建配置
├── mspm0g3507.lds          # 链接脚本（Linker Script）
├── probe-rs_supportd.txt   # Probe-rs 调试支持文件
├── README.md               # 项目说明文档
└── run.sh                  # 构建/运行脚本（Shell）
```

---

## 📦 环境依赖

- [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain)
- [CMake](https://cmake.org/download/)
- [Ninja](https://ninja-build.org/)
- [VS Code](https://code.visualstudio.com/)（推荐安装 Clangd 插件）

---

## ⚙️ 构建命令

在终端中运行以下命令完成构建：

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE
cmake --build build
```

---

## 🛠️ Probe-rs 烧录与调试

### 烧录与复位

```bash
# 烧录程序
probe-rs download --chip MSPM0G3507 build/your.elf

# 复位芯片
probe-rs reset --chip MSPM0G3507
```

### VS Code 调试配置（launch.json 示例）

如需在 Debug 模式下使用 VS Code 调试，可使用以下配置：

```json
"configurations": [
    {
        "type": "probe-rs-debug",
        "request": "launch",
        "name": "probe-rs Debug (MSPM0G3507)",
        "cwd": "${workspaceFolder}",
        "connectUnderReset": false,
        "chip": "MSPM0G3507",
        "flashingConfig": {
            "flashingEnabled": true,
            "haltAfterReset": true
        },
        "coreConfigs": [
            {
                "coreIndex": 0,
                "programBinary": "build/empty.elf"
            }
        ]
    }
]
```

更多调试配置说明详见 [Probe-rs 官方文档](https://probe.rs/docs/tools/debugger/)。

---

## 🧪 已验证平台

- 微控制器：MSPM0G3507
- 构建工具链：ARM GCC 14.x
- IDE 支持：VS Code + Clangd / CMake Tools / Probe-rs

---

## 📝 更新日志

> 记录项目的重要更新内容。

### v1.0.1 - 2025-05-28
- 新增 BSP 模块用于存放驱动代码。
- 添加 `probe-rs_supportd.txt` 支持文件。
- 优化 CMakeLists.txt 构建配置。
- 丰富 `README.md` 文档，加入调试配置说明。
- 改进 `run.sh` 自动化脚本。
- 测试自定义 VS Code 插件与 probe-rs 联调功能。

### v1.0.0 - 2025-05-27
- 初始模板发布。
- 完成项目结构搭建（Core, Driver 等目录）。
- 集成 CMake + ARM GCC + Ninja 构建链。
- 添加 VS Code 支持与 Clang 格式配置。
- 提供基础构建脚本 `run.sh`。

---

## 📄 许可证

本项目基于 MIT 许可证，详见 [LICENSE](./LICENSE)。

---

## 🙋‍♂️ 贡献与反馈

欢迎提交 Issue 和 PR！如需支持其他 MSPM0 系列芯片，欢迎参与共建。
