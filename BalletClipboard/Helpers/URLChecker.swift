import Foundation

/// URL 检测器 — 使用 NSDataDetector 识别链接
enum URLChecker {

    private static let detector: NSDataDetector? = {
        try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }()

    /// 判断字符串是否为 URL
    static func isURL(_ text: String) -> Bool {
        guard let detector = detector else { return false }
        let range = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, options: [], range: range)
        return matches.contains { match in
            match.range == range && match.resultType == .link
        }
    }
}
