import UIKit

public enum InstagramError: LocalizedError {
    case missingURLScheme
    case missingStickerImageData
    case couldNotOpenInstagram
}

public enum OptionsKey: String {
    case stickerImage = "com.instagram.sharedSticker.stickerImage"
    case backgroundImage = "com.instagram.sharedSticker.backgroundImage"
    case backgroundVideo = "com.instagram.sharedSticker.backgroundVideo"
    case backgroundTopColor = "com.instagram.sharedSticker.backgroundTopColor"
    case backgroundBottomColor = "com.instagram.sharedSticker.backgroundBottomColor"
    case contentURL = "com.instagram.sharedSticker.contentURL"
}

public enum InstagramOpenOutcome {
    case openedStories
    case openedInstagramApp
    case openedAppStore
}

@MainActor
final class InstagramRepository {
    static let shared = InstagramRepository()
    private init() {}

    // 自分のFacebook App ID（Info.plistと一致）
    private let facebookAppID = "1121974383444617"

    // 起動URL（必須：source_application）
    private var storiesURL: URL? {
        URL(string: "instagram-stories://share?source_application=\(facebookAppID)")
    }
    private var instagramAppURL: URL? { URL(string: "instagram://app") }
    // Instagram公式のApp Store ID
    private var instagramStoreURL: URL? { URL(string: "itms-apps://itunes.apple.com/app/id389801252") }

    /// 共有実行＋起動フォールバック。結果を返す。
    @discardableResult
    func share(
        stickerImage: UIImage,
        backgroundTopColor: String,
        backgroundBottomColor: String,
        contentURL: URL
    ) async throws -> InstagramOpenOutcome {
        guard let storiesURL else { throw InstagramError.missingURLScheme }
        guard let stickerData = stickerImage.pngData() else { throw InstagramError.missingStickerImageData }

        var items: [String: Any] = [
            OptionsKey.stickerImage.rawValue: stickerData,
            OptionsKey.backgroundTopColor.rawValue: backgroundTopColor,
            OptionsKey.backgroundBottomColor.rawValue: backgroundBottomColor,
            OptionsKey.contentURL.rawValue: contentURL.absoluteString
        ]
        // 任意だが安全側
        items["com.facebook.sharedSticker.appID"] = facebookAppID

        UIPasteboard.general.setItems([items],
            options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
        )

        // ① Stories直起動
        if UIApplication.shared.canOpenURL(storiesURL) {
            await UIApplication.shared.open(storiesURL)
            return .openedStories
        }

        // ② アプリ本体へ（ログイン状態などでStories画面に行けない端末でも、とりあえず起動）
        if let appURL = instagramAppURL, UIApplication.shared.canOpenURL(appURL) {
            await UIApplication.shared.open(appURL)
            return .openedInstagramApp
        }

        // ③ 未インストールっぽい → App Store へ
        if let storeURL = instagramStoreURL {
            await UIApplication.shared.open(storeURL)
            return .openedAppStore
        }

        throw InstagramError.couldNotOpenInstagram
    }
}
