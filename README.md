# FlexCom

![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)
![License](https://img.shields.io/badge/License-MIT-green)

> 🔌 现代化、跨平台的串口调试助手

## 简介

**FlexCom** 是一个基于 Flutter 开发的串口调试工具，专为嵌入式开发者和硬件调试人员设计。采用 Isolate 架构确保串口 I/O 操作不阻塞 UI，提供流畅的用户体验。

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

### 规划中
- 🧮 独立校验计算器窗口
- 🔄 简易自动回复
- 📈 数据波形可视化

## 🚀 快速开始

### 环境要求
- Flutter 3.35+
- Dart 3.9+
- Windows 10/11

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
| 框架 | Flutter |
| 语言 | Dart |
| 状态管理 | Riverpod |
| 串口通信 | flutter_libserialport |
| 架构 | Feature-first + Repository Pattern |

## 📄 License

MIT License - 详见 [LICENSE](LICENSE) 文件
