# CLAUDE.md — Ballet Clipboard 工作指引

> Claude Code 自动加载此文件了解项目上下文和工作方式。

---

## 项目概述

**Ballet Clipboard（芭蕾剪贴板）** — macOS 少女心粉色芭蕾风格剪贴板历史管理工具。自动记录复制内容（文字/图片/链接），支持搜索、去重、点击回贴。

**当前状态**：P0 核心功能已完成 ✅ | P1 开发中 🚧 | P2 计划中 📋

## 技术栈

- **语言**: Swift 6.0
- **UI**: SwiftUI `WindowGroup`（调试）/ `MenuBarExtra`（正式）
- **数据**: Core Data (SQLite) + FileManager (图片)
- **架构**: MVVM + Combine
- **项目生成**: XcodeGen (`project.yml`)
- **最低系统**: macOS 14.0
- **IDE**: Xcode 16.0

## 标准文档路径

| 文档 | 路径 | 说明 |
|------|------|------|
| 需求文档 | [docs/01-需求文档.md](docs/01-需求文档.md) | 功能清单、用户画像、验收标准 |
| 技术规范 | [docs/02-技术规范.md](docs/02-技术规范.md) | 架构设计、数据模型、线程安全 |
| 设计规范 | [docs/03-设计规范.md](docs/03-设计规范.md) | 色彩系统、排版、组件、图标 |
| 开发步骤 | [docs/04-开发步骤.md](docs/04-开发步骤.md) | 分阶段执行、验证清单 |
| 开发日志 | [devlog/](devlog/) | `YYYY-MM-DD.md` 每日记录 |

## 项目结构

```
/Users/daisy/Desktop/copy2/
├── README.md                       # 项目说明
├── CLAUDE.md                       # 本文件
├── project.yml                     # XcodeGen 项目配置
├── generate_icons.py               # 应用图标生成脚本
├── docs/                           # 标准文档
├── devlog/                         # 开发日志
├── BalletClipboard.xcodeproj/      # Xcode 项目（xcodegen generate）
└── BalletClipboard/                # 源代码目录
    ├── Info.plist                   # LSUIElement 控制 Dock 显隐
    ├── BalletClipboard.entitlements # App Sandbox
    ├── Assets.xcassets/            # AppIcon + MenuBarIcon + AccentColor
    ├── BalletClipboard.xcdatamodeld/  # Core Data 模型定义
    ├── App/
    │   ├── BalletClipboardApp.swift # @main 入口
    │   └── AppDelegate.swift        # 应用生命周期
    ├── Models/
    │   ├── ClipType.swift           # text / image / url 枚举
    │   └── ClipboardEntry.swift     # Core Data NSManagedObject
    ├── Data/
    │   ├── PersistenceController.swift # Core Data 栈 + 合并策略
    │   ├── ClipboardMonitor.swift      # 剪贴板轮询 + 类型识别 + 去重
    │   ├── ImageStore.swift            # 图片文件 CRUD
    │   └── CleanupEngine.swift         # 自动清理（骨架）
    ├── ViewModels/
    │   └── ClipboardViewModel.swift    # 状态管理 + 搜索 + 复制/删除
    ├── Views/
    │   ├── ContentView.swift           # 主容器 (360×500)
    │   ├── ClipCardView.swift          # 卡片组件
    │   ├── SearchBarView.swift         # 搜索栏
    │   ├── SettingsView.swift          # 设置面板
    │   └── EmptyStateView.swift        # 空状态 🩰
    ├── Theme/
    │   └── BalletTheme.swift           # 芭蕾粉色主题色
    └── Helpers/
        ├── URLChecker.swift            # NSDataDetector URL 检测
        └── RelativeTimeFormatter.swift # 中文相对时间
```

## 编译与运行

```bash
# 重新生成 Xcode 项目（新增文件后需要）
xcodegen generate

# 在 Xcode 中打开
open BalletClipboard.xcodeproj

# 仅命令行编译
xcodebuild -project BalletClipboard.xcodeproj \
  -scheme BalletClipboard \
  -configuration Debug build

# 清理编译
xcodebuild -project BalletClipboard.xcodeproj \
  -scheme BalletClipboard \
  -configuration Debug clean build
```

## 图片与图标

```bash
# 重新生成应用图标（修改设计后）
python3 generate_icons.py
```

图标设计：白色圆底 + 玫瑰粉爱心 + 浅粉翅膀 · 少女心风格。
`generate_icons.py` 使用纯 Python stdlib（无外部依赖），生成 PNG 到 `Assets.xcassets/`。

## 工作原则

1. **安全第一**：所有数据本地存储，不上传网络，沙盒化
2. **逐步推进**：每完成一个文件立即编译验证，不跃进
3. **中文注释**：代码注释使用中文，公开 API 使用文档注释
4. **先编译再继续**：每次改动后 ⌘B 确认编译通过
5. **日志同步**：每个开发日结束时更新 `devlog/YYYY-MM-DD.md`

## 关键设计决策

| 决策 | 理由 |
|------|------|
| Core Data 而非 SwiftData | 后台线程写入控制更成熟 |
| XcodeGen 而非手写 pbxproj | 可靠、可重复、社区标准 |
| 图片存文件系统 | 避免 SQLite 膨胀 |
| 0.5s 轮询剪贴板 | NSPasteboard 无推送通知，轮询唯一可靠 |
| WindowGroup 调试 / MenuBarExtra 正式 | 方便开发调试，正式切换仅需改代码 |
| `@unchecked Sendable` | Swift 6 严格并发下快速适配，后续可逐步加强 |
| `@preconcurrency import CoreData` | Core Data API 尚未完全适配 Swift 6 并发 |

## 当前版本状态

- **v1.0-dev** (2026-06-17)
- P0 核心功能 ✅ | P1 重要功能 🚧 | P2 体验增强 📋
