# 🩰 Ballet Clipboard（芭蕾剪贴板）

[![Swift](https://img.shields.io/badge/Swift-6.0-FA7343)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14.0%2B-8E8E93)](https://developer.apple.com/macos/)
[![Xcode](https://img.shields.io/badge/Xcode-16.0-1575F9)](https://developer.apple.com/xcode/)

> 💕 少女心粉色芭蕾风格 · macOS 剪贴板历史管理工具

自动记录复制的文字、图片、链接，常驻菜单栏，随时找回。

---

## ✨ 功能

| 状态 | 功能 | 说明 |
|------|------|------|
| ✅ 已完成 | 剪贴板监听 | 自动捕获 ⌘C 复制内容（文字/图片/链接） |
| ✅ 已完成 | 历史列表 | 粉色卡片式展示，时间降序，点击复制回剪贴板 |
| ✅ 已完成 | 类型识别 | 文字 / 图片 / URL 自动分类，不同图标 |
| ✅ 已完成 | 去重 | 连续复制相同内容不产生重复记录 |
| ✅ 已完成 | 搜索 | 实时过滤文字内容 |
| ✅ 已完成 | 复制粘贴 | 点击卡片 → ⌘V 粘贴到任意 App |
| 🚧 开发中 | 置顶/删除 | 单条置顶、删除管理 |
| 📋 计划中 | 自动清理 | 1/3/5 天过期自动删除 |
| 📋 计划中 | 开机启动 | 系统启动时自动运行 |

---

## 🚀 快速开始

### 环境要求

- macOS 14.0+
- Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### 编译运行

```bash
# 1. 生成 Xcode 项目
xcodegen generate

# 2. 打开项目
open BalletClipboard.xcodeproj

# 3. ⌘R 运行
```

### 命令行编译

```bash
xcodebuild -project BalletClipboard.xcodeproj \
  -scheme BalletClipboard \
  -configuration Debug build
```

---

## 📁 项目结构

```
copy2/
├── README.md                       # 本文件
├── CLAUDE.md                       # Claude Code 工作指引
├── project.yml                     # XcodeGen 配置
├── generate_icons.py               # 图标生成脚本
├── docs/                           # 标准文档
│   ├── 01-需求文档.md
│   ├── 02-技术规范.md
│   ├── 03-设计规范.md
│   └── 04-开发步骤.md
├── devlog/                         # 开发日志
├── BalletClipboard.xcodeproj/      # Xcode 项目（由 XcodeGen 生成）
└── BalletClipboard/                # 源代码
    ├── Info.plist
    ├── Assets.xcassets/            # 🎨 图标 + 配色
    ├── BalletClipboard.xcdatamodeld/  # Core Data 模型
    ├── App/                        # 应用入口
    ├── Models/                     # 数据模型
    ├── Data/                       # Core Data + 监听 + 清理
    ├── ViewModels/                 # 状态管理
    ├── Views/                      # SwiftUI 视图
    ├── Theme/                      # 芭蕾粉色主题
    └── Helpers/                    # 工具类
```

---

## 🎨 设计

- **主色调**：芭蕾粉 `#F2C4CE` / 玫瑰粉 `#D4788F`
- **图标**：白色圆底 + 粉色爱心 + 翅膀 · 少女心风格
- **风格**：圆角卡片、柔和阴影、粉色渐变

---

## 🔒 安全

- 所有数据**仅本地存储**
- **不上传任何数据**到网络
- 不申请网络权限
- App Sandbox 沙盒化

---

## 📄 许可

Copyright © 2026. All rights reserved.
