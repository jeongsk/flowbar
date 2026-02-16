import Foundation
import SwiftUI

// MARK: - View Extensions
extension View {
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            return transform(self)
        } else {
            return AnyView(self)
        }
    }
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - String Extensions
extension String {
    func fuzzyMatch(_ query: String) -> Bool {
        let queryLower = query.lowercased()
        let targetLower = self.lowercased()

        var queryIndex = queryLower.startIndex
        var targetIndex = targetLower.startIndex

        while queryIndex < queryLower.endIndex && targetIndex < targetLower.endIndex {
            if queryLower[queryIndex] == targetLower[targetIndex] {
                queryIndex = queryLower.index(after: queryIndex)
            }
            targetIndex = targetLower.index(after: targetIndex)
        }

        return queryIndex == queryLower.endIndex
    }
}
