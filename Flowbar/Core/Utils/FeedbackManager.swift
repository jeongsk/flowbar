import Foundation
import Cocoa
import SwiftUI
import os

// MARK: - Feedback Manager
@MainActor
final class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()

    @Published var feedbackCategories: [FeedbackCategory] = []
    @Published var recentFeedback: [UserFeedback] = []

    private let feedbackURL = URL(string: "https://github.com/Fission-AI/Flowbar/issues")!
    private let logger = Logger(subsystem: "com.flowbar.app", category: "Feedback")

    private init() {
        loadFeedbackCategories()
        loadRecentFeedback()
    }

    // MARK: - Feedback Categories
    private func loadFeedbackCategories() {
        feedbackCategories = [
            FeedbackCategory(
                id: "bug",
                name: "Bug Report",
                description: "Report a problem or crash",
                icon: "ladybug.fill"
            ),
            FeedbackCategory(
                id: "feature",
                name: "Feature Request",
                description: "Suggest a new feature or enhancement",
                icon: "lightbulb.fill"
            ),
            FeedbackCategory(
                id: "performance",
                name: "Performance Issue",
                description: "Report slow performance or high resource usage",
                icon: "speedometer"
            ),
            FeedbackCategory(
                id: "ux",
                name: "UX/UI Feedback",
                description: "Share your experience with the interface",
                icon: "paintbrush.fill"
            ),
            FeedbackCategory(
                id: "other",
                name: "Other",
                description: "Any other feedback or questions",
                icon: "ellipsis.bubble.fill"
            )
        ]
    }

    // MARK: - Submit Feedback
    func submitFeedback(_ feedback: UserFeedback) {
        logger.info("Submitting feedback: \(feedback.category)")

        // Save to recent feedback
        recentFeedback.append(feedback)

        // Keep only last 10 feedback items
        if recentFeedback.count > 10 {
            recentFeedback = Array(recentFeedback.suffix(10))
        }

        saveRecentFeedback()

        // Open GitHub issues with pre-filled information
        openGitHubIssue(for: feedback)
    }

    private func openGitHubIssue(for feedback: UserFeedback) {
        var components = URLComponents(url: feedbackURL, resolvingAgainstBaseURL: true)

        let title = "[\(feedback.category.uppercased())] \(feedback.title)"
        let body = generateIssueBody(for: feedback)

        components?.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "body", value: body)
        ]

        if let url = components?.url {
            NSWorkspace.shared.open(url)
        }
    }

    private func generateIssueBody(for feedback: UserFeedback) -> String {
        var body = """
        ## Description
        \(feedback.description)

        ## Category
        \(feedback.category)

        ## Steps to Reproduce (if applicable)
        \(feedback.steps.isEmpty ? "N/A" : feedback.steps)

        ## Expected Behavior
        \(feedback.expectedBehavior.isEmpty ? "N/A" : feedback.expectedBehavior)

        ## Actual Behavior
        \(feedback.actualBehavior.isEmpty ? "N/A" : feedback.actualBehavior)

        ## Environment
        """

        // Add system information
        body += "\n- macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)"
        body += "\n- Flowbar Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")"
        body += "\n- Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")"

        // Add performance metrics if available
        let optimizationManager = OptimizationManager.shared
        body += "\n\n## Performance Metrics"
        body += "\n- Memory Usage: \(optimizationManager.memoryUsage)"
        body += "\n- CPU Usage: \(optimizationManager.cpuUsage)"

        return body
    }

    // MARK: - Crash Reporting
    func reportCrash(_ crash: CrashReport) {
        logger.error("Crash reported: \(crash.reason)")

        // Save crash report
        let crashData = try? JSONEncoder().encode(crash)

        if let crashData = crashData {
            let crashesURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Flowbar")
                .appendingPathComponent("Crashes")

            try? FileManager.default.createDirectory(at: crashesURL, withIntermediateDirectories: true)

            let crashFile = crashesURL
                .appendingPathComponent("crash_\(Int(Date().timeIntervalSince1970)).json")

            try? crashData.write(to: crashFile)
        }

        // Prompt user to report
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Flowbar Crashed"
            alert.informativeText = "A crash report has been generated. Would you like to submit it to help improve Flowbar?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Submit Report")
            alert.addButton(withTitle: "Later")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                self.submitCrashReport(crash)
            }
        }
    }

    private func submitCrashReport(_ crash: CrashReport) {
        let feedback = UserFeedback(
            category: "bug",
            title: "Crash Report: \(crash.reason)",
            description: crash.stackTrace,
            steps: crash.userActions,
            expectedBehavior: "",
            actualBehavior: "Application crashed"
        )

        submitFeedback(feedback)
    }

    // MARK: - User Satisfaction Survey
    func requestSatisfactionSurvey() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "How's your experience with Flowbar?"
            alert.informativeText = "Would you mind taking a moment to rate your experience?"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Rate Now")
            alert.addButton(withTitle: "Later")
            alert.addButton(withTitle: "Don't Ask Again")

            let response = alert.runModal()

            switch response {
            case .alertFirstButtonReturn:
                self.showSatisfactionSurvey()
            case .alertThirdButtonReturn:
                self.disableSatisfactionSurvey()
            default:
                break
            }
        }
    }

    private func showSatisfactionSurvey() {
        // Create survey window
        let surveyView = SatisfactionSurveyView { rating in
            self.submitSatisfactionRating(rating)
        }

        let hostingController = NSHostingController(rootView: surveyView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Flowbar Satisfaction Survey"
        window.contentViewController = hostingController
        window.center()

        NSApp.runModal(for: window)
    }

    private func submitSatisfactionRating(_ rating: Int) {
        logger.info("User satisfaction rating: \(rating)")

        // Submit anonymous rating
        let feedback = UserFeedback(
            category: "other",
            title: "Satisfaction Rating: \(rating)/5",
            description: "User satisfaction rating",
            steps: "",
            expectedBehavior: "",
            actualBehavior: "Rating: \(rating)"
        )

        submitFeedback(feedback)
    }

    private func disableSatisfactionSurvey() {
        UserDefaults.standard.set(true, forKey: "satisfactionSurveyDisabled")
    }

    // MARK: - Persistence
    private func saveRecentFeedback() {
        if let data = try? JSONEncoder().encode(recentFeedback) {
            UserDefaults.standard.set(data, forKey: "recentFeedback")
        }
    }

    private func loadRecentFeedback() {
        guard let data = UserDefaults.standard.data(forKey: "recentFeedback"),
              let feedback = try? JSONDecoder().decode([UserFeedback].self, from: data) else {
            return
        }

        recentFeedback = feedback
    }

    // MARK: - Feature Requests
    func submitFeatureRequest(_ title: String, description: String) {
        let feedback = UserFeedback(
            category: "feature",
            title: title,
            description: description,
            steps: "",
            expectedBehavior: description,
            actualBehavior: ""
        )

        submitFeedback(feedback)
    }

    // MARK: - Analytics (Opt-in Only)
    func trackEvent(_ event: String, properties: [String: Any] = [:]) {
        // Only track if user has opted in
        guard UserDefaults.standard.bool(forKey: "analyticsEnabled") else {
            return
        }

        logger.info("Event: \(event), Properties: \(properties)")

        // In a real implementation, this would send to an analytics service
        // For now, we just log locally
    }

    func enableAnalytics(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "analyticsEnabled")

        if enabled {
            trackEvent("analytics_enabled")
        }
    }
}

// MARK: - Feedback Models
struct FeedbackCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
}

struct UserFeedback: Identifiable, Codable {
    let id: UUID
    let category: String
    let title: String
    let description: String
    let steps: String
    let expectedBehavior: String
    let actualBehavior: String
    let date: Date

    init(
        category: String,
        title: String,
        description: String,
        steps: String,
        expectedBehavior: String,
        actualBehavior: String
    ) {
        self.id = UUID()
        self.category = category
        self.title = title
        self.description = description
        self.steps = steps
        self.expectedBehavior = expectedBehavior
        self.actualBehavior = actualBehavior
        self.date = Date()
    }
}

struct CrashReport: Codable {
    let reason: String
    let stackTrace: String
    let userActions: String
    let date: Date

    init(reason: String, stackTrace: String, userActions: String) {
        self.reason = reason
        self.stackTrace = stackTrace
        self.userActions = userActions
        self.date = Date()
    }
}

// MARK: - Satisfaction Survey View
struct SatisfactionSurveyView: View {
    @Environment(\.dismiss) private var dismiss
    let onRatingSubmitted: (Int) -> Void

    @State private var selectedRating: Int? = nil
    @State private var feedback: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("How satisfied are you with Flowbar?")
                .font(.title)
                .bold()

            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        selectedRating = rating
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: rating <= (selectedRating ?? 0) ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(rating <= (selectedRating ?? 0) ? .yellow : .secondary)

                            Text("\(rating)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if let rating = selectedRating {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Feedback (optional)")
                        .font(.headline)

                    TextEditor(text: $feedback)
                        .frame(height: 100)
                }

                HStack {
                    Button("Skip") {
                        onRatingSubmitted(rating)
                        dismiss()
                    }

                    Spacer()

                    Button("Submit") {
                        onRatingSubmitted(rating)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var feedbackManager = FeedbackManager.shared

    @State private var selectedCategory: FeedbackCategory?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var steps: String = ""
    @State private var expectedBehavior: String = ""
    @State private var actualBehavior: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Send Feedback")
                .font(.title)
                .bold()

            Form {
                Section("Category") {
                    Picker("Select a category", selection: $selectedCategory) {
                        ForEach(feedbackManager.feedbackCategories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category as FeedbackCategory?)
                        }
                    }
                }

                if let category = selectedCategory {
                    Section("Details") {
                        TextField("Title", text: $title)
                            .textFieldStyle(.roundedBorder)

                        TextEditor(text: $description)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.secondary.opacity(0.3))
                            )

                        if category.id == "bug" {
                            TextField("Steps to reproduce", text: $steps, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)

                            TextField("Expected behavior", text: $expectedBehavior)
                                .textFieldStyle(.roundedBorder)

                            TextField("Actual behavior", text: $actualBehavior)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Submit") {
                    submitFeedback()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(selectedCategory == nil || title.isEmpty || description.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }

    private func submitFeedback() {
        guard let category = selectedCategory else { return }

        let feedback = UserFeedback(
            category: category.id,
            title: title,
            description: description,
            steps: steps,
            expectedBehavior: expectedBehavior,
            actualBehavior: actualBehavior
        )

        feedbackManager.submitFeedback(feedback)
        dismiss()
    }
}

// MARK: - Crash Handler
class CrashHandler {
    static let shared = CrashHandler()

    private init() {
        setupCrashHandler()
    }

    private func setupCrashHandler() {
        // Set up crash handler
        NSSetUncaughtExceptionHandler { exception in
            CrashHandler.shared.handleCrash(exception: exception)
        }
    }

    private func handleCrash(exception: NSException) {
        let crash = CrashReport(
            reason: exception.reason ?? "Unknown reason",
            stackTrace: exception.callStackSymbols.joined(separator: "\n"),
            userActions: "User actions not available"
        )

        Task { @MainActor in
            await FeedbackManager.shared.reportCrash(crash)
        }
    }
}
