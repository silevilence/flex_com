# Project Context
本项目 **"FlexCom"** 是一个基于 Flutter 开发的现代化、跨平台串口调试助手。

# Tech Stack & Libraries
- **Framework**: Flutter (Latest Stable)
- **Language**: Dart
- **State Management**: `flutter_riverpod` (必须使用，严禁混用 GetX 或 Provider)
- **Serial Port**: `flutter_libserialport`
- **Database**: `isar` (用于存储历史记录、指令列表)
- **Utils**: `equatable` (对象比较), `intl` (时间格式化)
- **Testing**: `flutter_test`, `mockito`
- **Architecture**: Feature-first architecture + Repository Pattern.
- **Concurrency**: 串口读取与协议解析必须在单独的 `Isolate` 中运行，禁止阻塞 UI 线程。

# Development Workflow & Rules

## 1. Package Management
- 添加/删除/更新包时，**必须**使用 Flutter CLI 命令：
  - Add: `flutter pub add <package_name>`
  - Remove: `flutter pub remove <package_name>`
  - Get: `flutter pub get`
- 禁止手动修改 `pubspec.yaml` 文本内容来管理依赖版本。

## 2. Feature Development (TDD Style)
- **Step 1 (Test)**: 编写单元测试 (`test/`)。
- **Step 2 (Code)**: 实现功能。
- **Step 3 (Lint)**: 运行 `flutter analyze`。**必须消除所有警告 (Warnings) 和建议 (Infos/Lints)**，除非修复这些警告会直接破坏功能逻辑（需在汇报时说明）。
- **Step 4 (Self-Verify)**: 运行 `flutter test` 确保通过。
- **Step 5 (Run)**: 运行 `flutter run -d windows` 确保启动正常。
- **Step 6 (Report)**: 汇报：“已完成 [功能名]，代码静态分析通过（无警告），单元测试已通过，应用运行正常。请测试。” 并附带测试方法。

## 3. Bug Fixing Protocol
- 收到 Bug 反馈 -> 创建复现用例 -> 确认失败 -> 修复代码 -> 消除 Lint 警告 -> 回归测试 -> 提交验证。

## 4. Documentation Guidelines
- **禁止自动更新**: 未经我明确确认，禁止修改 `README.md`, `ROADMAP.md` 或 `copilot-instructions.md`。
- **更新指令**: 仅在接收到 "更新文档" 相关指令时执行。

## 5. Git Commit Convention
- 在我要求提交代码时，生成 Git 提交消息。
- **格式**:
  ```text
  <Emoji> <Type>: <Summary>
  
  [Optional Body] Detailed description...
  ```
- **规则**:
  - 第一行：必填，Emoji + 类型 + 简要描述。
  - 第二行：空行。
  - 第三行：可选。如果简要描述已足够就不需要再加；如果需要，则对提交内容进行详细描述。
- **Type & Emoji Mapping**:
  - ✨ `feat`: 新功能
  - 🐛 `fix`: 修复 Bug
  - ♻️ `refactor`: 代码重构（不改变逻辑）
  - 📝 `docs`: 文档变更
  - ✅ `test`: 测试用例变更
  - 🔧 `chore`: 构建配置、依赖更新
  - 💄 `style`: 代码格式、UI 样式微调
- **推送规则**: 你只生成 commit 命令或消息，**由我手动执行 push**。

## 6. Project Structure Standard (Feature-first)
项目严格遵循 Feature-first 架构。开发新功能时，必须保持此结构整洁。
- `lib/core/`: 通用组件 (Constants, Theme, Utils, Shared Widgets).
- `lib/features/`: 业务模块 (按功能分包).
    - `<feature_name>/domain/`: 实体 (Entities), 状态类 (States).
    - `<feature_name>/data/`: 数据源 (DataSources), 仓库实现 (RepositoryImpls), DTOs.
    - `<feature_name>/application/`: 业务逻辑 (Providers, Notifiers, Services).
    - `<feature_name>/presentation/`: UI 组件 (Widgets, Pages, Controllers).
- `lib/main.dart`: 应用入口.

**维护规则**: 每次引入新的顶层文件夹或重构结构后，必须同步更新本章节。

---

# Documentation Standards

## README.md Structure
1.  **Header**: FlexCom, Badges.
2.  **Introduction**: 项目简介与核心卖点.
3.  **Features**: 功能列表.
4.  **Getting Started**: 安装运行指南.
5.  **Tech Stack**: 技术栈.

## ROADMAP.md Structure (Kanban + Priority)
文档必须遵循以下看板结构，使用 Emoji 标记优先级：

### 优先级图例 (Legend)
- 🔴 **P0 (Critical)**: 核心阻断性功能，必须优先完成。
- 🟡 **P1 (Important)**: 重要功能，虽不阻断流程但影响完整性。
- 🟢 **P2 (Nice to have)**: 锦上添花的功能，延后处理。

### 结构模版：

```markdown
# 🗺️ Product Roadmap

## 📝 计划中 (Planned)
> 待开发的需求池，按优先级排序

- [ ] 🔴 **[P0] 核心模块名称**
    - [ ] 细分任务 A
    - [ ] 细分任务 B
- [ ] 🟡 **[P1] 次要功能模块**
- [ ] 🟢 **[P2] 扩展功能**

## 🚧 开发中 (In Progress)
> 当前正在进行的工作 (WIP)

- [ ] 🔴 **[P0] 当前正在做的功能**
    - [ ] 任务 1
    - [ ] 任务 2 (编写测试中...)

## ✅ 已完成 (Completed)
> 已验收通过的功能

- [x] 🔴 **[P0] 基础设施搭建**
```