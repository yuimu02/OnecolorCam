//
//  HomeView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/23.
//

// HomeView.swift

import SwiftUI
//import SimpleCamera
import ColorfulX
import AppleSignInFirebase

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(AuthManager.self) var authManager
    
    var body: some View {
        
        if authManager.isSignedIn {
//            Text("Signed In!")
//            Button("Sign Out") {
//                try? authManager.signOut()
//            }
//            .buttonStyle(.borderedProminent)
            
            
            NavigationStack {
                ZStack {
                    Color.white
                    ColorfulView(color: $viewModel.colors)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text(viewModel.formattedDate)
                            .font(.system(size: 20))
                            .padding()
                            .foregroundColor(.black)
                        
                        HStack {
                            Button("赤") {
                                viewModel.selectColor(hue: 0.99, range: 0.1)
                            }
                            Button("緑") {
                                viewModel.selectColor(hue: 0.33, range: 0.13)
                            }
                            Button("青") {
                                viewModel.selectColor(hue: 0.66, range: 0.08)
                            }
                            Button("元に戻す") {
                                viewModel.resetColorRange()
                            }
                        }
                        .padding()
                        
                        //                    Image("Sample")
                        //                        .resizable()
                        //                        .aspectRatio(contentMode: .fit)
                        //                        .colorEffect(
                        //                            Shader(
                        //                                function: ShaderFunction(
                        //                                    library: .bundle(.main),
                        //                                    name: "sample"
                        //                                ),
                        //                                arguments: [
                        //                                    .float(viewModel.hueToDisplay),
                        //                                    .float(viewModel.range),
                        //                                    .color(viewModel.color)
                        //                                ]
                        //                            )
                        //                        )
                        
                        Button("trst") {
                            viewModel.showNextView = true
                        }
                    }
                    .onAppear {
                        viewModel.updateDate()
                    }
                    .sheet(
                        isPresented: Binding(
                            get: { viewModel.takenPhoto != nil },
                            set: { _ in viewModel.takenPhoto = nil }
                        )
                    ) {
                        if let image = viewModel.takenPhoto {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
            }
        } else {
            SignInWithAppleFirebaseButton()
        }
    }
}

#Preview {
    HomeView()
}

