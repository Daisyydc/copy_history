import SwiftUI

/// 芭蕾主题 — 粉色系色彩系统
enum BalletTheme {

    // MARK: - Colors

    /// 芭蕾粉 — 主品牌色
    static let balletPink = Color(red: 0.949, green: 0.769, blue: 0.808)

    /// 浅粉 — 卡片/次级背景
    static let lightPink = Color(red: 0.984, green: 0.914, blue: 0.929)

    /// 深粉 — 强调态/选中态
    static let deepPink = Color(red: 0.910, green: 0.627, blue: 0.706)

    /// 玫瑰粉 — 按钮/链接
    static let rosePink = Color(red: 0.831, green: 0.471, blue: 0.561)

    /// 金色 — 置顶标识
    static let gold = Color(red: 0.831, green: 0.659, blue: 0.325)

    /// 暖白 — 面板背景
    static let warmWhite = Color(red: 1.0, green: 0.980, blue: 0.984)

    // MARK: - Gradients

    static let headerGradient = LinearGradient(
        colors: [balletPink, lightPink],
        startPoint: .top,
        endPoint: .bottom
    )
}
