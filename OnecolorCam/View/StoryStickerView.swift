

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
                .aspectRatio(contentMode: .fill)
                .frame(width: 260, height: 260)
                .clipped()
                .cornerRadius(16)

                HStack(spacing: 8) {
                    Text(created.formatted(date: .numeric, time: .omitted))
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .lineLimit(1)
                    Circle()
                        .fill(Color(hex: publicColorHex) ?? .black)
                        .frame(width: 14, height: 14)
                }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 300, height: 360)
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}
