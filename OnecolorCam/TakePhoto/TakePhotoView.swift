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
        ZStack {
            SimpleCameraView(trigger: $trigger) { uiimage in
                print("photo taken")
            }
            .ignoresSafeArea()
            VStack {
                Spacer()
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
                .padding(.bottom, 40)
            }
        }
    }
}
