//
//  VoiceEntryView.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import SwiftUI
import Speech
import AVFoundation

// MARK: - Speech Recognizer

class SpeechRecognizerService: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String?

    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        // Prefer Indian English for better rupee/Indian merchant recognition
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))
            ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    func startRecording() {
        guard !isRecording else { return }
        transcript = ""
        errorMessage = nil

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let request = recognitionRequest else { return }
            request.shouldReportPartialResults = true

            let inputNode = audioEngine.inputNode
            recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self?.transcript = result.bestTranscription.formattedString
                    }
                    if error != nil || (result?.isFinal ?? false) {
                        self?.stopRecording()
                    }
                }
            }

            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Microphone unavailable. Please check permissions."
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// MARK: - Voice Entry View

struct VoiceEntryView: View {
    @Environment(\.dismiss) private var dismiss
    var onExpenseParsed: (ParsedVoiceExpense) -> Void

    @StateObject private var speechService = SpeechRecognizerService()
    @State private var parsedExpense: ParsedVoiceExpense?
    @State private var isAuthorized = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showPermissionAlert = false

    private var hasResult: Bool { parsedExpense != nil && !(speechService.transcript.isEmpty) }

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                if hasResult, let expense = parsedExpense {
                    resultView(expense)
                } else {
                    recordingView
                }
            }
            .navigationTitle("Voice Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        speechService.stopRecording()
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primary)
                }
                if hasResult {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Retry") {
                            withAnimation {
                                parsedExpense = nil
                                speechService.transcript = ""
                            }
                        }
                        .foregroundColor(Constants.Colors.primary)
                    }
                }
            }
            .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow microphone and speech recognition access in Settings to use Voice Entry.")
            }
        }
        .onAppear {
            speechService.requestAuthorization { granted in
                isAuthorized = granted
                if !granted { showPermissionAlert = true }
            }
        }
        .onDisappear {
            speechService.stopRecording()
        }
    }

    // MARK: - Recording View

    private var recordingView: some View {
        VStack(spacing: Constants.Spacing.xl) {
            Spacer()

            // Tips
            exampleTipsCard

            // Mic button area
            VStack(spacing: Constants.Spacing.lg) {
                // Live transcript bubble
                if !speechService.transcript.isEmpty {
                    transcriptBubble
                } else if speechService.isRecording {
                    Text("Listening…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.textSecondary)
                        .transition(.opacity)
                }

                // Mic Button
                ZStack {
                    // Outer pulse rings
                    if speechService.isRecording {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(Constants.Colors.accent.opacity(0.3 - Double(i) * 0.08), lineWidth: 2)
                                .frame(width: 100 + CGFloat(i * 28), height: 100 + CGFloat(i * 28))
                                .scaleEffect(pulseScale)
                                .animation(
                                    .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                    value: pulseScale
                                )
                        }
                    }

                    Circle()
                        .fill(
                            speechService.isRecording
                                ? LinearGradient(colors: [Constants.Colors.accent, Color(hex: "FF4F4F")],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Constants.Colors.primary, Color(hex: "8B6FFF")],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 90, height: 90)
                        .shadow(
                            color: (speechService.isRecording ? Constants.Colors.accent : Constants.Colors.primary).opacity(0.4),
                            radius: 20, y: 6
                        )

                    Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    guard isAuthorized else { showPermissionAlert = true; return }
                    if speechService.isRecording {
                        speechService.stopRecording()
                        let transcript = speechService.transcript
                        if !transcript.isEmpty {
                            withAnimation(.spring()) {
                                parsedExpense = VoiceExpenseParser.parse(transcript)
                            }
                        }
                    } else {
                        parsedExpense = nil
                        speechService.startRecording()
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            pulseScale = 1.12
                        }
                    }
                }

                Text(speechService.isRecording ? "Tap to stop" : "Tap to speak")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textSecondary)

                if let error = speechService.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding(Constants.Spacing.md)
        .animation(.easeInOut, value: speechService.isRecording)
    }

    // MARK: - Transcript Bubble

    private var transcriptBubble: some View {
        HStack(alignment: .top, spacing: Constants.Spacing.sm) {
            Image(systemName: "waveform")
                .font(.system(size: 16))
                .foregroundColor(Constants.Colors.primary)
                .padding(.top, 2)

            Text(speechService.transcript)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Constants.Colors.textPrimary)
                .multilineTextAlignment(.leading)
                .animation(.easeInOut, value: speechService.transcript)
        }
        .padding(Constants.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                .fill(Constants.Colors.primary.opacity(0.06))
        )
        .padding(.horizontal, Constants.Spacing.lg)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Example Tips

    private var exampleTipsCard: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "FF9500"))
                Text("Try saying…")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.textSecondary)
            }

            let examples = [
                "Spent 250 on lunch",
                "Paid 500 at Zomato",
                "150 rupees for petrol",
                "Grocery shopping 1200"
            ]

            ForEach(examples, id: \.self) { example in
                HStack(spacing: 6) {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 10))
                        .foregroundColor(Constants.Colors.primary.opacity(0.7))
                    Text(example)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
        .padding(Constants.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
        .padding(.horizontal, Constants.Spacing.md)
    }

    // MARK: - Result View

    private func resultView(_ expense: ParsedVoiceExpense) -> some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {

                // Transcript
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    Label("You said", systemImage: "waveform.and.mic")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Constants.Colors.textSecondary)

                    Text("\"\(speechService.transcript)\"")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(Constants.Colors.textPrimary)
                        .italic()
                }
                .padding(Constants.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                        .fill(Constants.Colors.primary.opacity(0.06))
                )

                // Parsed Fields Card
                VStack(alignment: .leading, spacing: 0) {
                    Text("Parsed Expense")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.textSecondary)
                        .padding(.bottom, Constants.Spacing.sm)

                    VStack(spacing: 0) {
                        voiceResultRow(
                            icon: "indianrupeesign.circle.fill",
                            label: "Amount",
                            value: expense.amount.map { "₹\(String(format: "%.0f", $0))" } ?? "Not detected",
                            color: Constants.Colors.success,
                            detected: expense.amount != nil
                        )
                        Divider().padding(.leading, 52)

                        voiceResultRow(
                            icon: "tag.fill",
                            label: "Category",
                            value: expense.categoryName ?? "Other",
                            color: Constants.Colors.primary,
                            detected: true
                        )
                        Divider().padding(.leading, 52)

                        voiceResultRow(
                            icon: "text.bubble.fill",
                            label: "Description",
                            value: expense.description.isEmpty ? speechService.transcript : expense.description,
                            color: Constants.Colors.secondary,
                            detected: true
                        )
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(Constants.CornerRadius.md)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                }

                // Add Expense Button
                Button(action: {
                    onExpenseParsed(expense)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Expense")
                    }
                }
                .primaryButtonStyle()
                .shadow(color: Constants.Colors.primary.opacity(0.3), radius: 10, y: 4)
            }
            .padding(Constants.Spacing.md)
        }
    }

    private func voiceResultRow(icon: String, label: String, value: String, color: Color, detected: Bool) -> some View {
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
            }
        }
        .padding(Constants.Spacing.md)
    }
}
