生成脚本：
```
 frb_plugin_tool_ohos presetup  -s ~/.ohos/script -o "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony" -f
```
编译鸿蒙arm64 lib
```
cargo build --target aarch64-unknown-linux-ohos --release
```


# Flutter与Rust混合开发入门指南


## 1 Flutter Rust Bridge

**FRB（Flutter Rust Bridge）** 是一个 Flutter/Dart 与 Rust 之间的绑定生成器，让你可以在 Flutter 应用中直接调用 Rust 代码，利用 Rust 的性能和安全性。

### 1.1 核心特性

- **自动生成桥接代码**：无需手动编写 FFI（Foreign Function Interface），只需编写正常的 Rust 代码
- **支持任意类型**：Struct、Enum、Option、Result、泛型等
- **异步编程支持**：async/await、线程池、Stream
- **双向调用**：Dart 调用 Rust，Rust 也可以调用 Dart
- **多平台支持**：Android、iOS、macOS、Windows、Linux

### 1.2 工作原理

1. 代码生成阶段
   - 分析 Rust 代码中的 `#[frb]` 标记，自动生成 Dart 绑定代码和 Rust 胶水代码
   - 处理类型转换和内存管理
2. 运行时绑定
   - 通过 FFI 实现通信
   - 自动处理内存分配和释放，支持零拷贝数据传输

## 2 鸿蒙适配

### 2.1 flutter_rust_bridge_ohos

FRB 的鸿蒙平台扩，提供鸿蒙系统的运行时适配。

### 2.2 frb_plugin_tool_ohos

快速生成 FRB 插件项目的命令行工具，支持多平台，包括鸿蒙。

## 3 环境搭建

### 3.1 Rust 编译 Target 安装

```bash
# Android
rustup target add aarch64-linux-android    # ARM64，主流设备
rustup target add armv7-linux-androideabi  # ARM32，老设备
rustup target add x86_64-linux-android     # x86_64，模拟器
rustup target add i686-linux-android       # x86，老模拟器

# iOS
rustup target add aarch64-apple-ios        # ARM64 真机
rustup target add aarch64-apple-ios-sim    # ARM64 模拟器（Apple Silicon Mac）
rustup target add x86_64-apple-ios         # x86_64 模拟器（Intel Mac）

# 鸿蒙
rustup target add aarch64-unknown-linux-ohos  # ARM64 真机
rustup target add x86_64-unknown-linux-ohos   # x86_64 模拟器
```

### 3.2 fvm 安装

fvm（Flutter Version Management）是一个用于管理多个 Flutter SDK 版本的命令行工具，它能让开发者在不同项目间轻松切换和使用指定的 Flutter 版本。

**安装命令：**

```bash
dart pub global activate fvm
```

**常用命令：**

```bash
# 查看版本
fvm --version

# 查看帮助
fvm --help

# 安装 Flutter 版本
fvm install xxx

# 查看已安装版本，该命令可能会比较慢
fvm list

# 使用指定版本
fvm use xxx
```

通过 fvm 安装的 Flutter 在 `~/fvm/versions` 目录下，之前已有的也可以移动到该目录。

对于非官方的版本（例如鸿蒙适配的版本），需要改为 `custom_xxx`，避免出现问题。

### 3.3 flutter_rust_bridge_codegen_ohos 安装

flutter_rust_bridge_codegen_ohos 是 FRB 的代码生成工具。

**安装命令：**

```bash
cargo install flutter_rust_bridge_codegen_ohos
```

**常用命令：**

```bash
# 查看版本
flutter_rust_bridge_codegen_ohos --version

# 查看帮助
flutter_rust_bridge_codegen_ohos --help

# 生成绑定代码
flutter_rust_bridge_codegen_ohos generate
```

### 3.4 frb_plugin_tool_ohos 安装

**安装命令：**

```bash
cargo install frb_plugin_tool_ohos
```

**常用命令：**

```bash
# 查看版本
frb_plugin_tool_ohos --version

# 查看帮助
frb_plugin_tool_ohos --help
```

### 3.5 鸿蒙开发环境配置

```bash
frb_plugin_tool_ohos presetup \
  -s <脚本目录> \
  -o <SDK 路径> \
  [-f]
```

**参数：**

- ```
  -s, --script-path
  ```

  : 脚本存放目录（必需）

  - 例如：`-s ~/.ohos/script`
  - 如果目录不存在会自动创建

- ```
  -o, --openharmony-path
  ```

  : OpenHarmony SDK 路径，可单独安装也可使用 DevEco Studio 里面的（必需）

  - 例如：`-o /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony`
  - 这是 SDK 的 native 目录的父路径

- ```
  -f, --force
  ```

  : 强制替换现有配置（可选）

  - 默认：`false`
  - 如果检测到已有配置，使用此选项强制覆盖

**示例：**

**普通模式（检测已有配置）：**

```bash
frb_plugin_tool_ohos presetup \
  -s ~/.ohos/script \
  -o /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony
```

**强制模式（覆盖现有配置）：**

```bash
frb_plugin_tool_ohos presetup \
  -s ~/.ohos/script \
  -o /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony \
  -f
```

该命令会自动：

1. 创建编译脚本

   （在



   ```
   -s
   ```



   参数指定的目录下）：

   - `aarch64-unknown-linux-ohos-clang.sh`
   - `aarch64-unknown-linux-ohos-clang++.sh`
   - `x86_64-unknown-linux-ohos-clang.sh`
   - `x86_64-unknown-linux-ohos-clang++.sh`
   - 自动设置可执行权限（755）

2. 配置 Cargo

   （

   ```
   ~/.cargo/config.toml
   ```

   ）：

   - 添加 `aarch64-unknown-linux-ohos` target 配置
   - 添加 `x86_64-unknown-linux-ohos` target 配置
   - 配置 linker 和 ar 工具路径
   - 设置 CC/CXX 环境变量

3. 智能处理

   ：

   - 检测已有配置（普通模式）
   - 强制替换旧配置（强制模式）
   - 自动创建必要的目录

## 4 Hello World 实战

### 4.1 创建插件项目

**命令：**

```bash
frb_plugin_tool_ohos create -n demo -f custom_3.22.0-ohos
```

**参数说明：**

- `-n, --name`: 插件名称（必需），如：demo
- `-f, --fvm-flutter-version`: Flutter 版本（必需），如：custom_3.22.0-ohos

**注意：如果创建失败或者慢，尝试开启代理。**

### 4.2 修改 flutter_rust_bridge_ohos 版本

创建完成后，修改 pubspec.yaml 中 flutter_rust_bridge_ohos 的版本为 2.11.2，2.11.1 在非鸿蒙上有问题。

2.11.1 中使用 `Platform.isOhos` 判断是否为鸿蒙，在非鸿蒙平台上调用 `Platform.isOhos` 会直接报错。

### 4.3 修改 flutter_rust_bridge 配置

修改 flutter_rust_bridge.yaml，内容如下：

```YAML
# 需要生成dart的rust代码文件
rust_input: rust/src/api/**/*.rs

# rust生成的基础代码目录
dart_output: lib/src
```

### 4.4 编写 Rust 函数

**编辑文件：** `rust/src/api/simple.rs`

```rust
use flutter_rust_bridge::frb;

/// 问候函数
///
/// # 参数
/// * `name` - 要问候的名称
///
/// # 返回值
/// 返回问候字符串
#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}
```

**说明：**

- `#[frb(sync)]` 标记表示生成同步调用的绑定代码
- 默认情况下（不添加标记）生成异步绑定代码
- 函数参数和返回值会自动进行类型转换

### 4.5 生成绑定代码

**命令：**

```bash
flutter_rust_bridge_codegen_ohos generate
```

**生成内容：**

- `lib/src/api/simple.dart` - Dart 绑定代码
- `lib/src/frb_generated.dart` - Dart 端生成代码
- `rust/src/frb_generated.rs` - Rust 端生成代码

### 4.6 Flutter 端调用

```dart
import 'package:flutter/material.dart';
import 'package:hpt_tracking/hpt_tracking.dart';

Future<void> main() async {
  // 初始化
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 调用Rust
    final hello = greet(name: "World");

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter + Rust Demo')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(hello, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

## 5 参考链接

- [flutter_rust_bridge](https://link.juejin.cn/?target=https%3A%2F%2Fcjycode.com%2Fflutter_rust_bridge%2F)
- [frb_plugin_tool_ohos](https://link.juejin.cn/?target=https%3A%2F%2Fgithub.com%2Fmdddj%2Ffrb_plugin_tool%2Fblob%2Fohos%2FREADME.md)
- [fvm](https://link.juejin.cn/?target=https%3A%2F%2Ffvm.app%2Fdocumentation%2Fgetting-started%2Foverview)

##