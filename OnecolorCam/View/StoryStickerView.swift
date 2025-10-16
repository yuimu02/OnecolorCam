

import SwiftUI

struct StoryStickerView: View {
    let image: UIImage
    let publicColorHex: String
    let urlString: String
    let created: Date

    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 260, height: 260)
                .clipShape(Rectangle())

                HStack(spacing: 8) {
                    Text(created.formatted(date: .numeric, time: .omitted))
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .lineLimit(1)
                    Circle()
                        .fill(Color(hex: publicColorHex) ?? .black)
                        .frame(width: 20, height: 20)
                }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 12)
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
        .frame(width: 300, height: 400)
        .padding(14)
        .background(Color.white)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}
