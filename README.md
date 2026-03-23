# Blackhole (黑洞实时渲染仪)

[English Version](README_en.md) | **简体中文版**

本项目是一个基于 OpenGL 的实时黑洞渲染演示程序。

## 视觉效果对比 (Visual Showcase)

| 原始项目演示 (Original Demo) | 当前全新中文构建版演示 (Current Demo) |
| :---: | :---: |
| ![Original Blackhole Demo](docs/blackhole-screenrecord.gif) | ![Current Blackhole Demo](docs/compressed_new_blackhole.gif) |

> **声明：** 本项目 Fork 自 Github 开源项目 [rossning92/Blackhole](https://github.com/rossning92/Blackhole)，由衷感谢原作者 Ross Ning 提供的精彩创意和核心着色器代码！

本项目最初是使用 C++、CMake 和 Conan 包管理器构建的。为了极大地简化环境配置流程并提供平滑的跨平台编译体验，目前整个项目系统已经**全面改造为 Zig 构建系统 (Zig Build System)**。你不再需要安装复杂的 C++ 构建环境或 Conan，只需要安装一个 Zig 编译器即可完成所有工作。

## Zig 逐步重构计划 (Migration Roadmap)

为了将此 C++ 项目优雅地过渡为 Zig 项目，我们制定了且正在实施以下四个重构阶段：

- [x] **第一阶段：使用 Zig 替换构建系统**
  - [x] 移除 `CMakeLists.txt` 和 Conan 依赖。
  - [x] 编写 `build.zig` 与 `build.zig.zon`，将 C++ 源文件交由 Zig 编译器。
  - [x] 配置 C 依赖包路径并由 Zig 管理及编译。
  - [x] 验证交叉编译 C++ 版本的图形与逻辑能够完美运行。
- [ ] **第二阶段：局部模块重用与改写**
  - [ ] 将 C 库相关底层文件 (`texture.cpp`) 重写为独立的 `.zig` 文件。
  - [ ] 提取并使用 Zig 重写 Shader 的读取及编译流程 (`shader.cpp`)。
  - [ ] 重构 `render.cpp` 中的 `Struct` 数据封装。
  - [ ] 将已完成的 `.zig` 模块通过 C ABI (C符号导出) 连回未改写的代码中。
- [ ] **第三阶段：主干逻辑与 GUI 适配**
  - [ ] 移除沉重的 C++ `imgui_impl_glfw` 绑定文件。
  - [ ] 引入原生的 `zgui` 等 Zig 极简 UI 库接管 Debug 界面。
  - [ ] 替换原程序的 C++ `glm` 库，改用更高效纯粹的 `zmath`。
  - [ ] 将 OpenGL 渲染循环主逻辑从 `main.cpp` 重置到 `main.zig` 中。
- [ ] **第四阶段：引入 Zig 专有安全护航**
  - [ ] 摒弃默认垃圾分配，全文件使用 `std.heap.GeneralPurposeAllocator` 获取内存。
  - [ ] 借助分配器捕捉程序结束时忘记调用的 `glDelete` 相关显存泄露。
  - [ ] 融入 Zig 独占的 `!void` 和 `catch` 对图形管线代码强制错误处理。

## 环境依赖

- **Zig 编译器**: 本项目使用了 Zig 0.15 版本的构建系统。请从 [Zig 官网](https://ziglang.org/) 下载安装最新版（或在终端使用 `scoop install zig` 等包管理器）。
- 所有 C++ 的第三方库依赖（GLFW, GLEW, GLM, Dear ImGui, stb_image）均已被静态化或放置在 `libs/` 目录下，并由 Zig 的 `build.zig` 统一纳管。**你不需要安装任何 C++ 编译器（如 MSVC 或 MinGW）**，Zig 本身自带了一个强大的 C/C++ 跨平台编译器！

## 如何运行、调试与构建

打开终端并进入到此项目根目录，你可以执行以下命令：

### 1. 直接编译并运行 (测试与调试)

最简单的方式，一行命令即可编译并运行程序：

```bash
zig build run
```

*提示：在开发着色器或改动 C++ 代码时，使用此命令能最快地观察到结果。此时默认开启的是 Debug 模式，拥有最多的安全检查。*

### 2. 编译打包生成 `.exe` (构建发布版)

如果你想把这个项目编译成一个独立的 `exe` 应用程序分享给别人，可以加上发布优化参数（ReleaseFast）：

```bash
zig build -Doptimize=ReleaseFast
```

这不仅会极大提高程序的运行帧率，还会进行体积压缩。

### 3. 构建产物在哪里？

编译成功后，一切你需要的东西都在项目生成的 `zig-out/` 文件夹中：

- 程序执行路径： `zig-out/bin/Blackhole.exe`
- 相关的动态链接库（`glfw3.dll`、`glew32.dll`）以及所有的着色器（`shader/` 文件夹）、图片资产（`assets/`文件夹）均会被 Zig 自动化构建流拷贝到 `zig-out/bin/` 目录下。
- 你可以直接打包压缩**整个 `zig-out/bin/` 文件夹**发送给没有任何编程环境的朋友，他们双击 `Blackhole.exe` 即可直接运行！

## Debug Panel (调试面板参数说明)

项目左上角依靠 Dear ImGui 提供了强大的实时调试面板，可以直接在程序运行时修改参数看到渲染变化：

### 核心物理效果

- `gravatationalLensing`：**引力透镜效应**开关。黑洞极强的引力使得背后的星系背景光线发生弯曲，产生奇妙的光斑变形。
- `renderBlackHole`：**黑洞本体（事件视界）**开关。关闭后将只保留吸积盘和背景星系，不再渲染中心的极黑区域。

### 摄像机控制

- `mouseControl`：开启鼠标拖曳控制（移动鼠标可改变观察视角）。
- `cameraRoll`：手动调节相机的横滚角（可以倾斜观看黑洞）。
- `frontView` / `topView`：快速切换到“正视图”或“顶视图”机位。

### 吸积盘调节 (Accretion Disk)

- `adiskEnabled`：**吸积盘**开关。吸积盘是黑洞周围由高速旋转发热物质组成的光环。
- `adiskParticle`：开启吸积盘的颗粒属性表现，使光效具有物质碎屑的云团感。
- `adiskDensityV` / `adiskDensityH`：分别调节吸积盘在垂直和水平方向上的物质分布密度。
- `adiskHeight`：改变吸积盘的结构厚度。
- `adiskLit`：吸积盘被中心辐射照亮的自发光/受光强度。
- `adiskNoiseLOD` / `adiskNoiseScale`：用于生成吸积盘表面湍流和扰动特征的“噪声复杂度”与“缩放比例”。
- `adiskSpeed`：吸积盘流体物质的公转与旋转速度。

### 后期处理 (Post-Processing)

- `bloomIterations` / `bloomStrength`：**辉光效应 (Bloom)**。控制光晕高模糊采样的迭代层级，以及整体散发光芒的烈度。
- `tonemappingEnabled` / `gamma`：**色调映射**与伽马校正。能确保最明亮的区域不会变成死白，通过 Gamma 值（推荐2.2左右）校正到人眼真实的感光曲线。

## 原作者信息 / Original Author

- **Author**: Ross Ning (<rossning92@gmail.com>)
- **Original Repo**: [https://github.com/rossning92/Blackhole](https://github.com/rossning92/Blackhole)
