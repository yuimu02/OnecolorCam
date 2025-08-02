//
//  TakePhotoView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/30.
//

import SwiftUI

struct TakePhotoView: View {
    
    @State var trigger = Trigger()
    
    var body: some View {
            VStack {
                GeometryReader { geometry in
                                let side = min(geometry.size.width - 40, geometry.size.height)
                                SimpleCameraView(trigger: $trigger) { uiimage in
                                    print("photo taken")
                                }
                                .frame(width: side, height: side)
                                .clipped()
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                .padding(.top, 40) // 少し上に余白
                            }
                            .aspectRatio(1, contentMode: .fit)
                
                Button() {
                    trigger.fire()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.6), lineWidth: 4)
                        )
                        .shadow(radius: 3)
                }
                .padding(.top, 33)
        }
    }
}
