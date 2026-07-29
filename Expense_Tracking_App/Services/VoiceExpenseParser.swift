//
//  VoiceExpenseParser.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import Foundation

// MARK: - Parsed Voice Expense

struct ParsedVoiceExpense {
    var amount: Double?
    var categoryName: String?
    var description: String
}

// MARK: - Voice Expense Parser

struct VoiceExpenseParser {

    /// Parses natural language strings like:
    ///   "Spent 250 on lunch"
    ///   "150 rupees for petrol"
    ///   "Paid 500 at Zomato"
    ///   "Grocery shopping 1200"
    static func parse(_ transcript: String) -> ParsedVoiceExpense {
        let lower = transcript.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        let amount    = extractAmount(from: lower)
        let category  = suggestCategory(from: lower)
        let desc      = buildDescription(from: transcript, amount: amount)

        return ParsedVoiceExpense(amount: amount, categoryName: category, description: desc)
    }

    // MARK: - Amount Extraction

    private static func extractAmount(from text: String) -> Double? {
        // Remove verbal filler words before extracting numbers
        let cleaned = text
            .replacingOccurrences(of: "rupees", with: "")
            .replacingOccurrences(of: "rupee", with: "")
            .replacingOccurrences(of: "rs", with: "")
            .replacingOccurrences(of: "inr", with: "")
            .replacingOccurrences(of: "₹", with: "")

        // Look for numbers (including decimals and comma-formatted)
        let pattern = #"\b(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)),
              let range = Range(match.range(at: 1), in: cleaned)
        else { return nil }

        let numStr = String(cleaned[range]).replacingOccurrences(of: ",", with: "")
        return Double(numStr)
    }

    // MARK: - Category Suggestion

    private static func suggestCategory(from text: String) -> String? {
        let categoryMap: [(keywords: [String], category: String)] = [
            (["food", "lunch", "dinner", "breakfast", "snack", "eat", "restaurant",
              "cafe", "swiggy", "zomato", "biryani", "pizza", "burger", "chai",
              "tea", "coffee", "dhaba", "meal", "canteen", "tiffin"],
             "Food & Dining"),
            (["petrol", "fuel", "diesel", "uber", "ola", "cab", "bus", "metro",
              "train", "auto", "taxi", "parking", "toll", "rapido", "travel", "flight"],
             "Transportation"),
            (["shop", "shopping", "cloth", "clothes", "shirt", "shoe", "amazon",
              "flipkart", "myntra", "market", "mall", "buy", "bought", "purchase"],
             "Shopping"),
            (["bill", "electricity", "water", "gas", "internet", "wifi", "mobile",
              "recharge", "jio", "airtel", "bsnl", "broadband", "subscription"],
             "Bills & Utilities"),
            (["doctor", "medicine", "pharmacy", "hospital", "clinic", "gym",
              "fitness", "health", "yoga", "medicine", "tablet", "injection"],
             "Health & Fitness"),
            (["movie", "netflix", "prime", "hotstar", "spotify", "game", "cinema",
              "pvr", "inox", "concert", "event", "entertainment", "show"],
             "Entertainment"),
            (["school", "college", "book", "course", "tuition", "coaching",
              "exam", "study", "education", "fee", "fees"],
             "Education"),
        ]

        for (keywords, category) in categoryMap {
            if keywords.contains(where: { text.contains($0) }) {
                return category
            }
        }
        return "Other"
    }

    // MARK: - Description Builder

    private static func buildDescription(from original: String, amount: Double?) -> String {
        // Remove filler phrases and leading words, keep the intent
        var desc = original
        let fillers = [
            "spent", "spend", "paid", "pay", "bought", "buy", "purchased",
            "rupees", "rupee", "rs.", "rs ", "inr", "₹",
            "on", "for", "at", "from", "in", "to"
        ]

        // Remove amount portion
        if let amt = amount {
            // Remove the numeric representation
            let amtPatterns = [
                String(Int(amt)),
                String(amt)
            ]
            for pat in amtPatterns {
                desc = desc.replacingOccurrences(of: pat, with: "", options: .caseInsensitive)
            }
        }

        for filler in fillers {
            desc = desc.replacingOccurrences(
                of: "\\b\(NSRegularExpression.escapedPattern(for: filler))\\b",
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        desc = desc
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return desc.isEmpty ? original : desc.prefix(1).uppercased() + desc.dropFirst()
    }
}
