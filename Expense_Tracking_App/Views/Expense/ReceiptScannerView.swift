//
//  ReceiptScannerView.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import SwiftUI
import UIKit

// MARK: - Camera / Photo Picker Representable

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        init(_ parent: ImagePickerView) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.selectedImage = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Receipt Scanner View

struct ReceiptScannerView: View {
    @Environment(\.dismiss) private var dismiss
    var onScanned: (ScannedReceiptData) -> Void

    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var scannedData: ScannedReceiptData?
    @State private var isScanning = false
    @State private var scanAngle: Double = 0

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                if let data = scannedData {
                    // Results screen
                    resultView(data)
                } else {
                    // Source selection screen
                    sourceSelectionView
                }
            }
            .navigationTitle("Receipt Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Constants.Colors.primary)
                }
                if scannedData != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Retake") {
                            withAnimation { scannedData = nil; selectedImage = nil }
                        }
                        .foregroundColor(Constants.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    ImagePickerView(selectedImage: $selectedImage, sourceType: .camera)
                        .ignoresSafeArea()
                }
            }
            .sheet(isPresented: $showGallery) {
                ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedImage) { _, image in
                guard let img = image else { return }
                scanImage(img)
            }
        }
    }

    // MARK: - Source Selection

    private var sourceSelectionView: some View {
        VStack(spacing: Constants.Spacing.xl) {
            Spacer()

            // Animated scanner icon
            ZStack {
                Circle()
                    .fill(Constants.Colors.primary.opacity(0.08))
                    .frame(width: 130, height: 130)
                Circle()
                    .fill(Constants.Colors.primary.opacity(0.12))
                    .frame(width: 100, height: 100)

                if isScanning {
                    Circle()
                        .stroke(
                            AngularGradient(colors: [Constants.Colors.primary, .clear],
                                            center: .center),
                            lineWidth: 3
                        )
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(scanAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                                scanAngle = 360
                            }
                        }
                }

                Image(systemName: isScanning ? "doc.viewfinder.fill" : "doc.viewfinder")
                    .font(.system(size: 44))
                    .foregroundColor(Constants.Colors.primary)
                    .symbolEffect(.pulse, isActive: isScanning)
            }

            VStack(spacing: 8) {
                Text(isScanning ? "Scanning Receipt…" : "Scan a Receipt")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Constants.Colors.textPrimary)

                Text(isScanning
                     ? "Extracting amount, date & merchant"
                     : "Point your camera at a receipt or\nchoose from your photo library")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if !isScanning {
                VStack(spacing: Constants.Spacing.md) {
                    // Camera button
                    Button(action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("Take Photo")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Constants.Colors.primary, Constants.Colors.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(Constants.CornerRadius.md)
                        .shadow(color: Constants.Colors.primary.opacity(0.3), radius: 10, y: 4)
                    }

                    // Gallery button
                    Button(action: { showGallery = true }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 18))
                            Text("Choose from Gallery")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Constants.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Constants.Colors.primary.opacity(0.1))
                        .cornerRadius(Constants.CornerRadius.md)
                    }
                }
                .padding(.horizontal, Constants.Spacing.lg)
            }

            Spacer()
        }
        .padding(Constants.Spacing.md)
    }

    // MARK: - Result View

    private func resultView(_ data: ScannedReceiptData) -> some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {
                // Success header
                successHeader

                // Receipt preview (show image if available)
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(Constants.CornerRadius.lg)
                }

                // Parsed fields
                parsedFieldsCard(data)

                // Use this data button
                Button(action: {
                    onScanned(data)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Use This Data")
                    }
                }
                .primaryButtonStyle()
                .shadow(color: Constants.Colors.primary.opacity(0.3), radius: 10, y: 4)
            }
            .padding(Constants.Spacing.md)
        }
    }

    private var successHeader: some View {
        HStack(spacing: Constants.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.success.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.Colors.success)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Receipt Scanned!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Constants.Colors.textPrimary)
                Text("Review the extracted data below")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(Constants.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                .fill(Constants.Colors.success.opacity(0.06))
        )
    }

    private func parsedFieldsCard(_ data: ScannedReceiptData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Extracted Information")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.textSecondary)
                .padding(.bottom, Constants.Spacing.sm)

            VStack(spacing: 0) {
                resultRow(
                    icon: "indianrupeesign.circle.fill",
                    label: "Amount",
                    value: data.amount.map { "₹\(String(format: "%.2f", $0))" } ?? "Not detected",
                    color: Constants.Colors.success,
                    detected: data.amount != nil
                )
                Divider().padding(.leading, 52)

                resultRow(
                    icon: "calendar",
                    label: "Date",
                    value: data.date.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) } ?? "Not detected",
                    color: Constants.Colors.primary,
                    detected: data.date != nil
                )
                Divider().padding(.leading, 52)

                resultRow(
                    icon: "building.2.fill",
                    label: "Merchant",
                    value: data.merchant ?? "Not detected",
                    color: Constants.Colors.secondary,
                    detected: data.merchant != nil
                )
                Divider().padding(.leading, 52)

                resultRow(
                    icon: "tag.fill",
                    label: "Category",
                    value: data.suggestedCategory ?? "Other",
                    color: Constants.Colors.accent,
                    detected: true
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(Constants.CornerRadius.md)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }

    private func resultRow(icon: String, label: String, value: String, color: Color, detected: Bool) -> some View {
        HStack(spacing: Constants.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Constants.Colors.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(detected ? Constants.Colors.textPrimary : Constants.Colors.textSecondary)
            }

            Spacer()

            if detected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.success)
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.textSecondary)
            }
        }
        .padding(Constants.Spacing.md)
    }

    // MARK: - Scan Logic

    private func scanImage(_ image: UIImage) {
        withAnimation { isScanning = true }
        ReceiptScannerService.scan(image: image) { data in
            withAnimation(.spring()) {
                self.scannedData = data
                self.isScanning = false
            }
        }
    }
}
