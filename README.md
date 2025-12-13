# FlexCom

![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)
![License](https://img.shields.io/badge/License-MIT-green)

> 🔌 现代化、跨平台的串口调试助手

## 简介

**FlexCom** 是一个基于 Flutter 开发的现代化串口调试助手，专为嵌入式开发者和硬件调试人员设计。采用 Isolate 架构确保串口 I/O 操作不阻塞 UI，提供流畅的用户体验。

核心特性：
- 🚀 **高性能架构**: Isolate 串口处理 + Riverpod 状态管理
- 🎯 **智能自动化**: 内置匹配回复和顺序回复系统，支持复杂通信协议测试
- 🧮 **完整工具链**: 校验计算器、多指令管理、数据日志等专业调试工具
- 🎨 **现代化 UI**: Material 3 设计 + VS Code 风格多区域布局

## ✨ 功能特性

### 已实现
- 🔧 **串口配置面板** - 完整的串口参数配置
  - 串口选择与刷新
  - 波特率 (300 ~ 921600)
  - 数据位 (5/6/7/8)
  - 停止位 (1/2)
  - 校验位 (None/Odd/Even/Mark/Space)
  - 流控 (None/RTS-CTS/XON-XOFF/DTR-DSR)
- ⚡ **Isolate 架构** - 串口操作在独立线程运行，UI 永不卡顿
- 🎨 **Material 3 设计** - 现代化 UI，支持亮/暗主题
- 📥 **基础收发功能** - Hex/ASCII 模式切换，实时数据显示
- 📊 **数据日志** - 通信日志实时/手动保存 (.txt/.bin)
- ⏱️ **定时发送** - 自定义间隔循环发送
- 🔢 **多条指令管理** - 预设指令列表，支持增删改查、拖拽排序
- 💾 **配置持久化** - 串口参数和指令列表自动保存
- 🧮 **独立校验计算器** - 完整的校验和算法支持
  - Checksum (Sum8/16), CRC8/16/32 (多种多项式变体)
  - XOR, MD5, SHA1/256 等摘要算法
  - Hex/ASCII 输入预览和自动转换
- 🔄 **智能自动回复系统** - 强大的串口自动化工具
  - **匹配回复模式**: 检测接收数据中的特征码，自动触发响应
  - **顺序回复模式**: 按预设帧列表顺序发送，支持循环播放
  - **可扩展架构**: 基于策略模式，支持自定义回复逻辑
  - **实时统计**: 接收/回复计数和最后匹配规则显示
- 🎯 **多区域布局** - VS Code 风格的可折叠面板系统
  - 左/右/底三个独立区域，支持面板移动和调整大小
  - Activity Bar 导航栏，点击展开/折叠面板
  - 灵活的面板配置和状态锁定

### 规划中
- 📈 **数据波形可视化** - 实时串口数据波形图绘制
- 🔧 **脚本化扩展** - Lua/Dart 脚本环境支持自定义逻辑
- 🌐 **网络调试** - TCP/UDP 客户端/服务器模式
- 📊 **高级数据分析** - 数据包解析和协议分析工具

## 🚀 快速开始

### 环境要求
- Flutter 3.35+
- Dart 3.9+
- Windows 10/11 (x64)
- Visual Studio 2022 (Windows 开发)

### 安装运行

```bash
# 克隆仓库
git clone https://github.com/silevilence/flex_com.git
cd flex_com

# 获取依赖
flutter pub get

# 运行应用
flutter run -d windows
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.35+ |
| 语言 | Dart 3.9+ |
| 状态管理 | Riverpod 3.x + riverpod_annotation |
| 串口通信 | flutter_libserialport |
| 数据库 | Isar (本地数据持久化) |
| UI 组件 | Material 3, multi_split_view |
| 工具库 | equatable, intl, crypto, path_provider |
| 代码生成 | freezed_annotation, build_runner |
| 架构 | Feature-first + Repository Pattern + Strategy Pattern |
: 接收/回复计数和最后匹配规则显示
- 🎯 **多区域布局** - VS Code 风格的可折叠面板系统
  - 左/右/底三个独立区域，支持面板移动和调整大小
  - Activity Bar 导航栏，点击展开/折叠面板
  - 灵活的面板配置和状态锁定

### 规划中
- 📈 **数据波形可视化** - 实时串口数据波形图绘制
- 🔧 **脚本化扩展** - Lua/Dart 脚本环境支持自定义逻辑
- 🌐 **网络调试** - TCP/UDP 客户端/服务器模式
- 📊 **高级数据分析** - 数据包解析和协议分析工具

## 🚀 快速开始

### 环境要求
- Flutter 3.35+
- Dart 3.9+
- Windows 10/11 (x64)
- Visual Studio 2022 (Windows 开发)

### 安装运行

```bash
# 克隆仓库
git clone https://github.com/silevilence/flex_com.git
cd flex_com

# 获取依赖
flutter pub get

# 运行应用
flutter run -d windows
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.35+ |
| 语言 | Dart 3.9+ |
| 状态管理 | Riverpod 3.x + riverpod_annotation |
| 串口通信 | flutter_libserialport |
| 数据库 | Isar (本地数据持久化) |
| UI 组件 | Material 3, multi_split_view |
| 工具库 | equatable, intl, crypto, path_provider |
| 代码生成 | freezed_annotation, build_runner |
| 架构 | Feature-first + Repository Pattern + Strategy Pattern |

## 📄 License

MIT License - 详见 [LICENSE](LICENSE) 文件
