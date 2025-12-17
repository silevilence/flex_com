# 🗺️ Product Roadmap

## 📝 计划中 (Planned)
> 待开发的需求池，按优先级排序

- [x]  **[P2] DTR/DSR 流控实现**
    - [x] 使用 SerialPort.signals API 手动控制 DTR 引脚（已实现，详见 `lib/features/serial/data/serial_isolate_service.dart`）
    - [x] 实现 DTR/DSR 握手流控逻辑（已实现，含单元测试，全部通过）

- [ ] 🟢 **[P2] 通用脚本系统 (General Scripting System)**
    - [ ] **核心架构与管理 (Core & Management)**
        - [ ] **脚本引擎**: 集成 Dart `eval` 或 Lua 环境，运行于独立的 Isolate 中以保障 UI 流畅性。
        - [ ] **脚本管理器**: 侧边栏/面板增加脚本管理页，支持文件的增删改查及简单语法高亮编辑。
        - [ ] **API 桥接**: 暴露 `FCom` 全局对象，提供 `send`, `log`, `delay`, `crc` 等核心能力。
    - [ ] **Hook 挂载机制 (Hooking Mechanism)**
        - [ ] **Pipeline Hook (数据流钩子)**: 允许将脚本挂载为“接收预处理器” (修改/解密 Rx 数据) 或“发送后处理器” (加封包/校验 Tx 数据)。
        - [ ] **Reply Hook (应答钩子)**: 接入 P1 的自动回复系统，支持“脚本模式”，实现复杂的条件判断应答逻辑。
        - [ ] **Task Hook (自动化任务)**: 支持手动触发脚本，用于执行一次性的发包序列或压力测试。
    - [ ] **调试控制台**: 独立的脚本日志输出窗口，用于打印调试信息 (`print`) 和显示错误堆栈。

- [ ] 🟢 **[P2] 网络扩展 (Network Extension)**
    - [ ] **抽象层重构**: 抽象出统一的 `IConnection` 接口，屏蔽串口与网络 Socket 的底层差异。
    - [ ] **TCP 支持**: 实现 TCP Client (连接服务端) 和 TCP Server (本地监听) 模式。
    - [ ] **UDP 支持**: 实现 UDP 单播与广播收发功能。

- [ ] 🟢 **[P2] 通用帧协议解析引擎 (Universal Frame Parser)**
    - [ ] **可扩展架构设计**:
        - 定义统一的 `IProtocolParser` 接口 (包含 `parse(Uint8List frame) -> ParsedFrame`)。
        - 采用**策略模式**管理协议库：新增协议仅需编写一个实现类 + 在枚举中注册，确保零耦合扩展。
    - [ ] **通用解析器实现 (MVP)**:
        - 实现一个基于配置的默认解析器。
        - **字节提取**: 支持配置“第 M 到 N 字节”作为数据段，支持指定端序 (Little/Big Endian) 和数据类型 (Int/Float/Double)。
        - **位域解析 (Bit-field)**: 支持在一个字节内通过掩码 (Mask) 或位索引提取 Flag 标志位。
    - [ ] **帧结构定义 UI**: 提供图形化界面配置帧头、帧尾、校验位位置及数据段提取规则，配置可保存为 JSON。

- [ ] 🟢 **[P2] 数据可视化 (Data Visualization)**
    - [ ] **数据源绑定 (Data Binding)**:
        - 实现与“协议解析引擎”的联动。
        - **选择器 UI**: 允许用户从当前协议解析出的字段列表（如 "Temperature", "Voltage", "StatusBit"）中，勾选需要作为 Y 轴数据的字段。
    - [ ] **绘图引擎集成**: 引入 `fl_chart` 或 `syncfusion_flutter_charts`。
    - [ ] **实时示波器**:
        - 实现多通道数据流的实时滚屏绘制。
        - 交互功能：支持波形暂停/继续、X/Y 轴缩放、十字游标测量 (Cursor)

## 🚧 开发中 (In Progress)
> 当前正在进行的工作

## ✅ 已完成 (Completed)
> 已验收通过的功能

- [x] 🟡 **[P1] 智能自动回复系统 - 基础功能 (Smart Auto-Reply System)**
    - [x] **可扩展架构**: 建立统一的回复处理器接口（策略模式）。新增回复模式只需实现 `ReplyHandler` 接口并添加枚举关联。
    - [x] **配置管理**: 实现分层配置结构，统一序列化保存至 `config.json`。
        - **全局设置**: 总开关、全局回复延迟 (Delay)、当前激活模式。
        - **模式设置**: 每种模式拥有独立的配置模型 (`MatchReplyConfig`, `SequentialReplyConfig`)。
    - [x] **模式 1: 匹配回复 (Match & Reply)**:
        - 配置: 触发规则 (Hex/Ascii 包含匹配) -> 响应内容 (Hex/Ascii)。
        - 逻辑: 接收流中检测到特定特征码即触发回复。
        - UI: 规则列表（添加/编辑/删除/启用开关/拖拽排序）。
    - [x] **模式 2: 顺序回复 (Sequential Reply)**:
        - 配置: 预设的一组帧列表。
        - 逻辑: 每次收到数据后，按顺序发送列表中的下一帧，支持循环。
        - 交互: UI 指示当前回复进度（指针），支持手动重置或跳转到指定帧。
    - [x] **自动回复引擎**: 监听串口数据流，自动处理并发送回复，统计接收/回复次数。
- [x] 🟡 **[P1] 独立校验与摘要计算器 (Checksum/Hash Calculator)**
    - [x] **算法支持**: 涵盖 Checksum (Sum8/16), CRC8/16/32 (多种多项式/初值变体), XOR, 以及摘要算法 (MD5, SHA1/256)。
    - [x] **架构设计**: 采用 **策略模式 (Strategy Pattern)** 封装算法逻辑，确保未来扩展新算法时无需修改 UI 层，仅需添加具体策略类。
    - [x] **UI 实现**: 独立的计算工具窗口，支持 Hex/Ascii 输入预览及自动转换，支持将待发送帧设置到计算帧，以及将结果附加到待发送帧后。
- [x] 🔴 **[P0] 多区域可折叠布局 (Multi-Zone Collapsible Layout)**
    - [x] **三区架构**: 引入 `multi_split_view`，实现 Left/Right/Bottom 三个可独立调整尺寸的面板区域。
    - [x] **Activity Bar**: 实现 VS Code 风格侧边导航栏，支持点击图标"展开/完全折叠"面板。
    - [x] **灵活配置**: 支持通过右键菜单将功能面板（如指令列表、波形）移动到不同区域 (L/R/B)。
    - [x] **状态锁定**: 确保串口配置面板固定在 Left 区域首位，不可移动。
- [x] 🟡 **[P1] 视图交互与日志 (UI/UX & Logging)**
    - [x] **UI 紧凑化重构**: 针对桌面端优化，将左侧串口配置面板缩小至目前的 70% 左右。
    - [x] **高级功能容器化 (Docking System)**: 初步规划完成，已升级为多区域布局方案。
    - [x] **通信日志**: 接收数据实时/手动保存为文件 (.txt / .bin)
    - [x] **接收优化**: 接收数据自动换行开关
    - [x] **接收优化**: 显示数据时间戳 (精确到ms)
    - [x] **接收优化**: 暂停屏幕滚动 / 一键清空接收区
    - [x] **状态监控**: Rx / Tx 字节计数器与复位功能
    - [x] **多条指令列表**: 多条预设指令面板 (支持添加、编辑、删除、拖拽排序)
    - [x] **数据持久化**: 使用 JSON 文件保存用户的指令列表 (`commands.json`)
    - [x] **快速发送**: 双击或点击发送按钮即可发送预设指令
- [x] 🟡 **[P1] 发送辅助工具 (Send Helpers)**
    - [x] 定时循环发送功能 (自定义间隔 ms)
    - [x] 快捷发送选项: 自动追加 `\r\n` (回车换行)
    - [x] 快捷发送选项: 自动追加校验位 (Checksum/CRC16-MODBUS)
- [x]  **[P0] 用户配置持久化 (User Settings Persistence)**
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
