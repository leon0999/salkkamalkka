//
//  AddWishItemView.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import SwiftUI
import PhotosUI

struct AddWishItemView: View {
    @ObservedObject var viewModel: WishListViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var url: String = ""
    @State private var memo: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    // 사진 추가
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Spacer()
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundColor(.mintGreen)
                                    Text("사진 추가")
                                        .font(.subheadline)
                                        .foregroundColor(.mintGreen)
                                }
                                .frame(height: 120)
                            }
                            Spacer()
                        }
                    }
                }

                Section(header: Text("무엇을 사고 싶나요?")) {
                    TextField("상품명 (필수)", text: $name)

                    HStack {
                        Text("₩")
                        TextField("가격 (필수)", text: $price)
                            .keyboardType(.numberPad)
                    }

                    TextField("구매 링크 (선택)", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)

                    TextField("왜 사고 싶나요? (선택)", text: $memo)
                        .lineLimit(3)
                }

                Section {
                    Button(action: addItem) {
                        HStack {
                            Spacer()
                            Text("7일 후 결정하기")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(canSubmit ? Color.mintGreen : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canSubmit)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("물건 등록")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("취소") {
                dismiss()
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    private var canSubmit: Bool {
        !name.isEmpty && !price.isEmpty && Int(price) != nil
    }

    private func addItem() {
        guard let priceValue = Int(price) else { return }

        viewModel.addWishItem(
            name: name,
            price: priceValue,
            url: url.isEmpty ? nil : url,
            memo: memo.isEmpty ? nil : memo,
            imageData: selectedImage?.jpegData(compressionQuality: 0.7)
        )

        dismiss()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
