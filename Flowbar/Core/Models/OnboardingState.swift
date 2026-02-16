import Foundation
import SwiftData

@Model
final class OnboardingState {
    var isComplete: Bool
    var lastStep: String
    var completedDate: Date?

    init(isComplete: Bool = false, lastStep: String = "") {
        self.isComplete = isComplete
        self.lastStep = lastStep
        self.completedDate = nil
    }

    func markStepComplete(_ step: String) {
        self.lastStep = step
    }

    func complete() {
        self.isComplete = true
        self.completedDate = Date()
    }
}
