//
//  ReceiptScannerService.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import UIKit
import Vision

// MARK: - Scanned Receipt Data

struct ScannedReceiptData {
    var amount: Double?
    var date: Date?
    var merchant: String?
    var suggestedCategory: String?
    var rawText: String
}

// MARK: - Receipt Scanner Service

struct ReceiptScannerService {

    // MARK: - Main Entry Point

    static func scan(image: UIImage, completion: @escaping (ScannedReceiptData) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ScannedReceiptData(rawText: ""))
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(ScannedReceiptData(rawText: ""))
                return
            }

            // Collect all text lines with their bounding box Y position (top → bottom)
            let lines: [(text: String, yPos: CGFloat)] = observations.compactMap { obs in
                guard let top = obs.topCandidates(1).first else { return nil }
                return (top.string, obs.boundingBox.minY)
            }
            // Vision coordinates: minY=0 is bottom, so sort descending for top-first
            .sorted { $0.yPos > $1.yPos }

            let rawText = lines.map(\.text).joined(separator: "\n")
            let result = parse(lines: lines.map(\.text), rawText: rawText)
            DispatchQueue.main.async { completion(result) }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    // MARK: - Parsing

    private static func parse(lines: [String], rawText: String) -> ScannedReceiptData {
        let amount = extractAmount(from: lines)
        let date   = extractDate(from: lines)
        let merchant = extractMerchant(from: lines)
        let category = suggestCategory(merchant: merchant, rawText: rawText)

        return ScannedReceiptData(
            amount: amount,
            date: date,
            merchant: merchant,
            suggestedCategory: category,
            rawText: rawText
        )
    }

    // MARK: - Amount Extraction

    private static func extractAmount(from lines: [String]) -> Double? {
        // Patterns: ₹1,250.00 | Rs.1250 | TOTAL 1250.00 | Grand Total: 1,250
        let patterns = [
            #"(?:₹|Rs\.?|INR)\s*([0-9,]+(?:\.[0-9]{1,2})?)"#,
            #"(?:total|grand\s*total|amount|subtotal)\s*[:\-]?\s*([0-9,]+(?:\.[0-9]{1,2})?)"#,
            #"\b([0-9,]+\.[0-9]{2})\b"#
        ]

        var candidates: [Double] = []

        for line in lines {
            let lower = line.lowercased()
            for pattern in patterns {
                if let match = matchGroup(pattern: pattern, in: lower, group: 1) {
                    let cleaned = match.replacingOccurrences(of: ",", with: "")
                    if let value = Double(cleaned), value > 0 && value < 1_000_000 {
                        // Prefer lines with "total" keyword
                        if lower.contains("total") || lower.contains("amount") {
                            return value
                        }
                        candidates.append(value)
                    }
                }
            }
        }
        // Return the largest candidate (likely the total)
        return candidates.max()
    }

    // MARK: - Date Extraction

    private static func extractDate(from lines: [String]) -> Date? {
        let formats = [
            "dd/MM/yyyy", "dd-MM-yyyy", "MM/dd/yyyy",
            "dd MMM yyyy", "dd-MMM-yy", "dd/MM/yy",
            "yyyy-MM-dd", "d MMM, yyyy", "d/M/yyyy"
        ]
        let datePattern = #"\b(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}|\d{1,2}\s+\w{3,9}\s+\d{2,4})\b"#

        for line in lines {
            if let raw = matchGroup(pattern: datePattern, in: line, group: 1) {
                for fmt in formats {
                    let df = DateFormatter()
                    df.dateFormat = fmt
                    df.locale = Locale(identifier: "en_IN")
                    if let d = df.date(from: raw) {
                        // Sanity check: within 5 years
                        let diff = abs(d.timeIntervalSinceNow)
                        if diff < 5 * 365 * 86400 { return d }
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Merchant Extraction

    private static func extractMerchant(from lines: [String]) -> String? {
        let skipPatterns = [
            "receipt", "invoice", "bill", "gst", "tax", "total",
            "date", "time", "address", "phone", "tel:", "thank",
            "www.", ".com", "cash", "paid", "change"
        ]

        for line in lines.prefix(6) {
            let lower = line.lowercased()
            let isMeta = skipPatterns.contains { lower.contains($0) }
            let hasOnlyNumbers = line.trimmingCharacters(in: .whitespaces).allSatisfy { $0.isNumber || $0 == "-" || $0 == "/" }

            if !isMeta && !hasOnlyNumbers && line.count >= 3 && line.count <= 50 {
                return line.trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    // MARK: - Category Suggestion

    private static func suggestCategory(merchant: String?, rawText: String) -> String? {
        let text = ((merchant ?? "") + " " + rawText).lowercased()

        let categoryMap: [(keywords: [String], category: String)] = [
            (["restaurant", "cafe", "swiggy", "zomato", "food", "biryani", "pizza",
              "burger", "dhaba", "hotel", "eatery", "kitchen", "dabba", "canteen",
              "lunch", "dinner", "breakfast", "snack", "bakery", "chai", "tea"],
             "Food & Dining"),
            (["uber", "ola", "bus", "metro", "train", "auto", "cab", "petrol",
              "fuel", "diesel", "parking", "toll", "taxi", "rapido", "flight"],
             "Transportation"),
            (["amazon", "flipkart", "myntra", "mall", "market", "store", "shop",
              "cloth", "shirt", "shoe", "apparel", "fashion", "retail"],
             "Shopping"),
            (["electricity", "water", "gas", "internet", "wifi", "airtel",
              "jio", "bsnl", "mobile", "recharge", "bill", "utility", "broadband"],
             "Bills & Utilities"),
            (["hospital", "doctor", "clinic", "pharmacy", "medicine", "health",
              "gym", "fitness", "yoga", "apollo", "max hospital"],
             "Health & Fitness"),
            (["netflix", "prime", "hotstar", "spotify", "movie", "cinema",
              "pvr", "inox", "game", "theatre", "concert", "event"],
             "Entertainment"),
            (["school", "college", "course", "book", "udemy", "coaching",
              "tuition", "exam", "university", "education", "study"],
             "Education"),
        ]

        for (keywords, category) in categoryMap {
            if keywords.contains(where: { text.contains($0) }) {
                return category
            }
        }
        return "Other"
    }

    // MARK: - Regex Helper

    private static func matchGroup(pattern: String, in text: String, group: Int) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > group,
              let range = Range(match.range(at: group), in: text)
        else { return nil }
        return String(text[range])
    }
}
