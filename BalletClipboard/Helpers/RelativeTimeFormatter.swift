import Foundation

/// 中文相对时间格式化
enum RelativeTimeFormatter {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh-Hans")
        return f
    }()

    /// 将 Date 转换为中文相对时间字符串
    static func format(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            return "\(Int(interval / 60)) 分钟前"
        } else if interval < 86400 {
            return "\(Int(interval / 3600)) 小时前"
        } else if interval < 172800 {
            return "昨天"
        } else if interval < 604800 {
            return "\(Int(interval / 86400)) 天前"
        } else {
            dateFormatter.dateFormat = "MM-dd HH:mm"
            return dateFormatter.string(from: date)
        }
    }
}
