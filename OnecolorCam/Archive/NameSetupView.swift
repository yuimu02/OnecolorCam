////
////  NameSetupView.swift
////  OnecolorCam
////
////  Created by Yuiko Muroyama on 2025/09/25.
////
//
//import SwiftUI
//import AppleSignInFirebase
//
//struct NameSetupView: View {
//    let uid: String
//    var onComplete: () -> Void
//
//    @State private var name: String = ""
//    @State private var isSaving = false
//    @State private var errorMessage: String?
//
//    // シンプルなバリデーション（空白のみ/長すぎ/改行NG を拒否）
//    private var isValid: Bool {
//        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        return !trimmed.isEmpty && trimmed.count <= 20 && !trimmed.contains(where: \.isNewline)
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("表示名を入力してください")
//                .font(.title3)
//                .bold()
//
//            TextField("例）Yuiko", text: $name)
//                .textInputAutocapitalization(.none)
//                .disableAutocorrection(true)
//                .submitLabel(.done)
//                .onSubmit { save() }
//                .padding()
//                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//                .padding(.horizontal)
//
//            Text("※ 一度設定すると変更できません")
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//
//            if let msg = errorMessage {
//                Text(msg).font(.footnote).foregroundStyle(.red)
//            }
//
//            Button {
//                save()
//            } label: {
//                if isSaving {
//                    ProgressView()
//                } else {
//                    Text("この名前で登録する")
//                        .bold()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(!isValid || isSaving)
//
//        }
//        .padding()
//    }
//
//    private func save() {
//        Task {
//            guard isValid else { return }
//            isSaving = true
//            errorMessage = nil
//            do {
//                // merge: true なので他フィールドは保持されます
//                try await FirebaseManager.updateUserName(uid: uid, name: name.trimmingCharacters(in: .whitespacesAndNewlines))
//                onComplete()
//            } catch {
//                errorMessage = error.localizedDescription
//            }
//            isSaving = false
//        }
//    }
//}
//
