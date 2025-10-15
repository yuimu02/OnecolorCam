

import SwiftUI

struct StoryStickerView: View {
    let image: UIImage
    let publicColorHex: String
    let urlString: String
    let created: Date

    var body: some View {
        VStack(spacing: 10) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 260)
                .clipped()
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: publicColorHex) ?? .black)
                        .frame(width: 14, height: 14)
                    Text("publiccolor: \(publicColorHex)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                }
                Text("created: \(created.formatted(date: .numeric, time: .omitted))")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 300, height: 360)
        .padding(14)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}
