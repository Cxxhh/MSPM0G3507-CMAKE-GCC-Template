
# MSPM0G3507-CMAKE-GCC-Clion

这是一个适用于 [TI MSPM0G3507 微控制器](https://www.ti.com/product/MSPM0G3507) 的嵌入式项目模板，基于 **CMake** 构建系统、**ARM GCC** 工具链，使用 **CLion** 作为主要开发环境，并集成 **OpenOCD** 实现程序烧录与调试。

本模板适用于裸机（无 RTOS）开发，提供高效的开发体验和清晰的工程结构。

> 💡尚未配置开发环境？可参考👉[STM32+Clion调试视频教程](https://www.bilibili.com/video/BV1pnjizYEAk/?spm_id_from=333.337.search-card.all.click)  
> 🌟环境配置完成 点击进入教程篇👉[教程地址](https://github.com/Cxxhh/MSPM0G3507-CMAKE-GCC-Template/blob/Clion/Configuration.md)  
> 🔄需要适配其他 MSPM0 系列芯片？可基于本模板裁剪移植  
 


---

## 🧱 项目结构

```
MSPM0-CMAKE-GCC-TEMPLATE/
├── BSP/                    # 第三方库文件
├── Core/                   # 主应用代码（如 main.c）
├── Driver/                 # 驱动代码，包括 CMSIS 和 TI DriverLib
├── tools/                  # 开发工具脚本，生成ti_msp_dl_config.c与.h文件
├── cmake-build-debug-mingw-mspm0_dev/  # CLion 构建输出目录（自动生成）
├── flash.cfg               # OpenOCD 烧录配置文件
├── mspm0g3507.lds          # 链接脚本（Linker Script）
├── CMakeLists.txt          # 顶层 CMake 构建配置
└── README.md               # 项目说明文档
```

---

## 📦 环境依赖

- [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain)
- [CMake](https://cmake.org/download/) (≥3.20)
- [OpenOCD](https://github.com/openocd-org/openocd) (👈自行编译)
- [CLion 2025.1](https://www.jetbrains.com/clion/) (25.1原生支持openocd 非商业免费)
- [Ninja](https://ninja-build.org/) (可选，用于命令行构建)  
or
- [STM32CubeCLT](https://www.st.com/en/development-tools/stm32cubeclt.html#get-software)(环境所需工具链都有)  
- [OpenOCD](https://github.com/openocd-org/openocd) (🏗️已经编译好的版本)
---

## ⚙️ 构建与烧录

### CLion 开发流程
1. **打开项目**：在 CLion 中直接打开本目录
2. **构建项目**：使用默认构建配置（Ctrl+F9）
3. **烧录程序**：
   - 配置 OpenOCD：`Tools > OpenOCD Download & Run`
   - 设置配置文件：`flash.cfg`
   - 设置 ELF 路径：`cmake-build-debug-mingw-mspm0_dev/your_app.elf`

---

## 🔧 OpenOCD 配置示例

`flash.cfg` 文件内容示例：
```ini
# MSPM0G3507 OpenOCD 配置
source [find interface/cmsis-dap.cfg]
source [find target/ti_mspm0.cfg]
# path_to_elf_file 为你的构建目录下的.elf文件 复制绝对路径
program <path_to_elf_file> verify reset
```

---

## 🧪 已验证环境

- **微控制器**：MSPM0G3507
- **构建工具链**：ARM GCC 14.x
- **开发环境**：CLion 2023.3
- **调试工具**：OpenOCD 0.12.0 + CMSIS-DAP

---

## 📝 更新日志

### v1.1.0 - 2025-06-01
- 迁移至 CLion + OpenOCD 开发环境
- 新增 OpenOCD 配置文件 `flash.cfg`
- 添加 `tools/` 目录存放开发脚本
- 优化 CMake 构建配置
- 更新文档说明

### v1.0.2 - 2025-05-29
- 新增 Windows 批处理脚本
- 添加 VS Code 任务配置

### v1.0.1 - 2025-05-28
- 新增 BSP 模块
- 优化 CMakeLists 配置
- 完善文档结构

---

## 📄 许可证

本项目基于 MIT 许可证，详见 [LICENSE](./LICENSE)。

---

## 🙋‍♂️ 贡献与反馈
欢迎交流 🐧：3054736043
欢迎提交 Issue 和 PR！如需支持其他 MSPM0 系列芯片，欢迎参与共建。
