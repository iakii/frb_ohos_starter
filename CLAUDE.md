# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Flutter FFI 插件，用 Rust 编写 native 代码，通过 `flutter_rust_bridge`（鸿蒙适配版）生成 Dart 绑定。支持 Android、iOS、Linux、macOS、Windows、HarmonyOS (ohos)。

## 常用命令

```bash
# 从 Rust API 生成 Dart 绑定代码（主要方式）
flutter_rust_bridge_codegen_ohos generate

# 从 C header 生成 Dart FFI 绑定（仅 src/ 下传统 C 路径使用）
dart run ffigen --config ffigen.yaml

# 单独编译鸿蒙 ARM64 Rust 库
cargo build --target aarch64-unknown-linux-ohos --release

# 检查 Rust 代码
cargo check
cargo clippy

# 检查 Dart 代码
dart analyze

# 在 example 中运行 Flutter 应用
cd example && flutter run

# 鸿蒙环境初始化（一次性，需 DevEco Studio SDK）
frb_plugin_tool_ohos presetup \
  -s ~/.ohos/script \
  -o "<SDK路径>/default/openharmony" \
  -f
```

## 架构关键点

### 双层 native 代码路径

项目同时存在两种 native 集成方式，不要混淆：

1. **Rust + flutter_rust_bridge**（推荐，`rust/` 目录）：Rust 函数写在 `rust/src/api/` 下，`flutter_rust_bridge_codegen_ohos generate` 读取 `flutter_rust_bridge.yaml` 配置，自动生成 Dart 绑定到 `lib/`。Rust crate 类型为 `cdylib + staticlib`。

2. **传统 C FFI**（`src/` 目录）：`src/rust_ohos_app.c/.h` 是模板自带的 C 实现，通过 `ffigen` 生成 `lib/rust_ohos_app_bindings_generated.dart`。目前仅在 `lib/rust_ohos_app.dart` 中使用。

### 构建流程

- 各平台构建（Android Gradle / iOS CocoaPods / Linux CMake / Windows CMake / ohos hvigor+CMake）触发 **cargokit**（vendored 在 `cargokit/`）
- cargokit 调用 `cargo build` 交叉编译 Rust crate，产物放入平台期望的目录
- 最终 Dart 端通过 FFI 加载 `.so`/`.dylib`/`.dll` 调用 native 函数

### 关键依赖说明

- `flutter_rust_bridge_ohos` (v2.11.x)：鸿蒙兼容的 FRB Dart 端运行时。**v2.11.1 在非鸿蒙平台调用 `Platform.isOhos` 会崩溃**，非鸿蒙调试需升级到 v2.11.2。
- `flutter_rust_bridge` = "2.11.1"（`rust/Cargo.toml`）：Rust 端 FRB crate，提供 `#[frb]` 宏。
- `frb_plugin_tool_ohos`：CLI 工具，用于 `presetup`（配置鸿蒙交叉编译工具链）和 `create`（创建新项目）。

### 鸿蒙 Rust target

鸿蒙需要自定义 Rust target（非 rustup 官方渠道）：
- `aarch64-unknown-linux-ohos`（ARM64 真机）
- `x86_64-unknown-linux-ohos`（x86_64 模拟器）

`presetup` 命令会自动向 `~/.cargo/config.toml` 写入这些 target 的 linker/ar 配置。

### 配置文件作用

| 文件 | 作用 |
|------|------|
| `flutter_rust_bridge.yaml` | 指定 `rust_input`（要生成绑定的 .rs 文件）和 `dart_output`（生成 Dart 代码目录） |
| `ffigen.yaml` | 指定要解析的 C header 和输出 Dart 文件路径 |
| `rust/Cargo.toml` | Rust crate 定义，依赖 `flutter_rust_bridge` |
| `cargokit/gradle/plugin.gradle` | Android 端 cargokit 构建逻辑，Android 构建时自动调用 cargo |
