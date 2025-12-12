# 🗺️ Product Roadmap

## 📝 计划中 (Planned)
> 待开发的需求池，按优先级排序

- [ ] 🟡 **[P1] UI 优化与交互增强 (UI/UX Enhancement)**
    - [ ] **UI 紧凑化重构**: 针对桌面端优化，将左侧串口配置面板缩小至目前的 70% 左右，提高屏幕利用率。
    - [ ] **高级功能容器化 (Docking System)**:
        - 实现类似 IDE 的可折叠/停靠侧边栏或底部面板。
        - 将"指令列表"、"脚本控制"、"波形图"等高级功能放入独立 Tab 页中。
        - 默认隐藏，点击按钮弹出，支持浮动或停靠。

- [ ] 🟢 **[P2] 高级协议工具 (Protocol Tools)**
    - [ ] 独立校验计算器窗口 (CRC16/32, XOR, Sum 等)
    - [ ] 简易自动回复 (根据接收到的特定 Hex 自动回复预设 Hex)

- [ ] 🟢 **[P2] DTR/DSR 流控实现**
    - [ ] 使用 SerialPort.signals API 手动控制 DTR 引脚
    - [ ] 实现 DTR/DSR 握手流控逻辑

- [ ] 🟢 **[P2] 脚本化与扩展 (Flexibility)**
    - [ ] **脚本引擎集成**: 引入 Lua 或 Dart Script 环境
    - [ ] **Hook 实现**: 实现 `onReceive` 数据拦截接口
    - [ ] **网络扩展**: TCP Client/Server, UDP 调试模式
    - [ ] **可视化**: 接收数据实时波形图绘制

## 🚧 开发中 (In Progress)
> 当前正在进行的工作

(暂无)

## ✅ 已完成 (Completed)
> 已验收通过的功能

- [x] 🟡 **[P1] 数据持久化与多条发送 (Persistence)**
    - [x] **多条指令列表**: 多条预设指令面板 (支持添加、编辑、删除、拖拽排序)
    - [x] **数据持久化**: 使用 JSON 文件保存用户的指令列表 (`commands.json`)
    - [x] **快速发送**: 双击或点击发送按钮即可发送预设指令
- [x] 🟡 **[P1] 发送辅助工具 (Send Helpers)**
    - [x] 定时循环发送功能 (自定义间隔 ms)
    - [x] 快捷发送选项: 自动追加 `\r\n` (回车换行)
    - [x] 快捷发送选项: 自动追加校验位 (Checksum/CRC16-MODBUS)
- [x] 🟡 **[P1] 视图交互与日志 (UI/UX & Logging)**
    - [x] **通信日志**: 接收数据实时/手动保存为文件 (.txt / .bin)
    - [x] **接收优化**: 接收数据自动换行开关
    - [x] **接收优化**: 显示数据时间戳 (精确到ms)
    - [x] **接收优化**: 暂停屏幕滚动 / 一键清空接收区
    - [x] **状态监控**: Rx / Tx 字节计数器与复位功能
- [x] 🔴 **[P0] 用户配置持久化 (User Settings Persistence)**
    - [x] 串口参数保存为 JSON 文件 (软件根目录下 `config.json`)
    - [x] 启动时自动加载上次的串口配置
    - [x] 支持保存: 串口名、波特率、数据位、停止位、校验位、流控
- [x] 🔴 **[P0] 基础收发功能 (Basic I/O)**
    - [x] **接收区**: 实时显示数据流
    - [x] **接收区**: 支持 Hex (十六进制) 与 ASCII 文本模式切换
    - [x] **发送区**: 基础文本/Hex 发送框
    - [x] **发送区**: 发送按钮与发送状态反馈
- [x] 🔴 **[P0] 串口配置 UI (Serial Config UI)**
    - [x] 串口选择下拉框（含刷新按钮）
    - [x] 波特率/数据位/停止位/校验位配置控件
    - [x] 打开/关闭串口按钮与状态指示
    - [x] 流控参数支持 (RTS/CTS, XON/XOFF, DTR/DSR 选项已添加)
- [x] 🔴 **[P0] 串口核心管理 (Serial Core) - 基础架构**
    - [x] 实现后台 Isolate 串口服务框架
    - [x] 串口列表自动扫描 API
    - [x] 串口打开/关闭状态管理与错误处理
    - [x] SerialPortConfig 数据模型 (波特率, 数据位, 停止位, 校验位)
- [x] 🔴 **[P0] 项目初始化 (Project Init)**
    - [x] 配置 `pubspec.yaml` (libserialport, riverpod, isar 等核心依赖)
    - [x] 建立 Feature-first 目录结构
    - [x] 配置 `flutter_lints` 规则
- [x] 🔴 **[P0] 文档规范制定** (`copilot-instructions.md`)
