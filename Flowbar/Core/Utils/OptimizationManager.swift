import Foundation
import SwiftUI
import SwiftData
import os

// MARK: - Optimization Manager
@MainActor
final class OptimizationManager: ObservableObject {
    static let shared = OptimizationManager()

    @Published var isProfiling: Bool = false
    @Published var memoryUsage: String = ""
    @Published var cpuUsage: String = ""

    private let logger = Logger(subsystem: "com.flowbar.app", category: "Performance")
    private var performanceMetrics: [String: [TimeInterval]] = [:]
    private let maxMetricsPerKey = 100

    private init() {}

    // MARK: - Profiling
    func startProfiling() {
        isProfiling = true
        logger.info("Performance profiling started")

        // Start monitoring
        startMemoryMonitoring()
        startCPUMonitoring()
    }

    func stopProfiling() {
        isProfiling = false
        logger.info("Performance profiling stopped")

        // Log summary
        logPerformanceSummary()
    }

    // MARK: - Memory Monitoring
    private func startMemoryMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isProfiling else {
                timer.invalidate()
                return
            }

            let memoryUsage = self.getCurrentMemoryUsage()
            DispatchQueue.main.async {
                self.memoryUsage = self.formatBytes(memoryUsage)
            }
        }
    }

    func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return info.resident_size
        }

        return 0
    }

    // MARK: - CPU Monitoring
    private func startCPUMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isProfiling else {
                timer.invalidate()
                return
            }

            let cpuUsage = self.getCurrentCPUUsage()
            DispatchQueue.main.async {
                self.cpuUsage = String(format: "%.1f%%", cpuUsage * 100)
            }
        }
    }

    private func getCurrentCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }

        if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(MemoryLayout<thread_basic_info>.size / MemoryLayout<integer_t>.size)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                        thread_info(threadsList[Int(index)],
                                 thread_flavor_t(THREAD_BASIC_INFO),
                                 $0,
                                 &threadInfoCount)
                    }
                }

                guard infoResult == KERN_SUCCESS else {
                    break
                }

                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            }

            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadsList), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        }

        return totalUsageOfCPU / 100.0
    }

    // MARK: - Performance Metrics
    func recordMetric(_ key: String, duration: TimeInterval) {
        if performanceMetrics[key] == nil {
            performanceMetrics[key] = []
        }

        performanceMetrics[key]?.append(duration)

        // Keep only recent metrics
        if let metrics = performanceMetrics[key], metrics.count > maxMetricsPerKey {
            performanceMetrics[key] = Array(metrics.suffix(maxMetricsPerKey))
        }

        logger.debug("Metric \(key): \(duration)s")
    }

    func getAverageMetric(for key: String) -> TimeInterval? {
        guard let metrics = performanceMetrics[key], !metrics.isEmpty else {
            return nil
        }

        return metrics.reduce(0, +) / Double(metrics.count)
    }

    func getMetricPercentile(for key: String, percentile: Double) -> TimeInterval? {
        guard let metrics = performanceMetrics[key], !metrics.isEmpty else {
            return nil
        }

        let sorted = metrics.sorted()
        let index = Int(Double(sorted.count) * percentile)

        return sorted[min(index, sorted.count - 1)]
    }

    // MARK: - Memory Leak Detection
    func detectMemoryLeaks() -> [String] {
        var leaks: [String] = []

        // Check for large memory usage
        let currentMemory = getCurrentMemoryUsage()
        let threshold: UInt64 = 500 * 1024 * 1024 // 500 MB

        if currentMemory > threshold {
            leaks.append("High memory usage: \(formatBytes(currentMemory))")
        }

        // Check for growing metrics (potential leaks)
        for (key, metrics) in performanceMetrics {
            if metrics.count > 10 {
                let firstHalf = Array(metrics.prefix(metrics.count / 2))
                let secondHalf = Array(metrics.suffix(metrics.count / 2))

                let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
                let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)

                // If second half is significantly slower, may indicate memory leak
                if secondAvg > firstAvg * 1.5 {
                    leaks.append("Possible leak in \(key): performance degradation detected")
                }
            }
        }

        return leaks
    }

    // MARK: - Startup Time Optimization
    func optimizeStartup() {
        logger.info("Optimizing startup time")

        // Pre-warm DataController
        _ = DataController.shared

        // Pre-load common data
        let modelContext = DataController.shared.modelContext

        // Load preferences
        let preferenceDescriptor = FetchDescriptor<Preference>()
        _ = try? modelContext.fetch(preferenceDescriptor)

        // Load modes
        let modeDescriptor = FetchDescriptor<Mode>()
        _ = try? modelContext.fetch(modeDescriptor)

        logger.info("Startup optimization complete")
    }

    // MARK: - Cleanup
    func cleanup() {
        logger.info("Performing cleanup")

        // Clear old performance metrics
        let keysToRemove = performanceMetrics.filter { _, metrics in
            metrics.isEmpty || metrics.count < 10
        }.map { $0.key }

        for key in keysToRemove {
            performanceMetrics.removeValue(forKey: key)
        }

        logger.info("Cleanup complete")
    }

    // MARK: - Logging
    private func logPerformanceSummary() {
        logger.info("=== Performance Summary ===")

        for (key, metrics) in performanceMetrics {
            if let avg = getAverageMetric(for: key),
               let p95 = getMetricPercentile(for: key, percentile: 0.95) {
                logger.info("\(key): avg=\(avg)s, p95=\(p95)s")
            }
        }

        logger.info("Current memory: \(self.memoryUsage)")
        logger.info("Current CPU: \(self.cpuUsage)")

        let leaks = detectMemoryLeaks()
        if !leaks.isEmpty {
            logger.warning("Potential issues detected:")
            for leak in leaks {
                logger.warning("\(leak)")
            }
        }

        logger.info("=== End Summary ===")
    }

    // MARK: - Formatting
    func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Performance Measure Utility
func measurePerformance<T>(key: String, operation: () throws -> T) rethrows -> T {
    let start = Date()
    let result = try operation()
    let duration = Date().timeIntervalSince(start)

    Task { @MainActor in
        OptimizationManager.shared.recordMetric(key, duration: duration)
    }

    return result
}

// MARK: - Memory Leak Detector
@MainActor
class MemoryLeakDetector {
    private var snapshots: [String: UInt64] = [:]

    func takeSnapshot(name: String) -> UInt64 {
        let memory = OptimizationManager.shared.getCurrentMemoryUsage()
        snapshots[name] = memory
        return memory
    }

    func detectGrowth(snapshotName: String, threshold: Double = 1.2) -> Bool {
        guard let previous = snapshots[snapshotName] else {
            return false
        }

        let current = OptimizationManager.shared.getCurrentMemoryUsage()
        let ratio = Double(current) / Double(previous)

        return ratio > threshold
    }

    func getGrowth(snapshotName: String) -> String? {
        guard let previous = snapshots[snapshotName] else {
            return nil
        }

        let current = OptimizationManager.shared.getCurrentMemoryUsage()
        let growth = current - previous

        return OptimizationManager.shared.formatBytes(growth)
    }
}

// MARK: - Startup Time Tracker
class StartupTimeTracker {
    private var milestones: [String: Date] = [:]

    func mark(_ milestone: String) {
        milestones[milestone] = Date()
    }

    func timeSince(_ milestone: String) -> TimeInterval? {
        guard let start = milestones[milestone] else {
            return nil
        }

        return Date().timeIntervalSince(start)
    }

    func report() -> String {
        var report = "Startup Timing:\n"

        let sorted = milestones.sorted { $0.value < $1.value }
        var previous: Date?

        for (name, date) in sorted {
            if let prev = previous {
                let elapsed = date.timeIntervalSince(prev)
                report += "  \(name): +\(String(format: "%.3f", elapsed))s\n"
            } else {
                let elapsed = Date().timeIntervalSince(date)
                report += "  \(name): \(String(format: "%.3f", elapsed))s total\n"
            }

            previous = date
        }

        return report
    }
}

// MARK: - Optimization Suggestions
struct OptimizationSuggestion {
    let category: String
    let title: String
    let description: String
    let priority: Priority

    enum Priority {
        case low
        case medium
        case high
    }
}

@MainActor
class OptimizationAdvisor {
    static func getSuggestions() -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []

        // Check memory usage
        let currentMemory = OptimizationManager.shared.getCurrentMemoryUsage()
        let memoryThreshold: UInt64 = 200 * 1024 * 1024 // 200 MB

        if currentMemory > memoryThreshold {
            suggestions.append(OptimizationSuggestion(
                category: "Memory",
                title: "High Memory Usage",
                description: "Consider implementing image caching or lazy loading for icons",
                priority: .medium
            ))
        }

        // Check for potential memory leaks
        let leaks = OptimizationManager.shared.detectMemoryLeaks()
        if !leaks.isEmpty {
            suggestions.append(OptimizationSuggestion(
                category: "Memory",
                title: "Potential Memory Leaks",
                description: leaks.joined(separator: ", "),
                priority: .high
            ))
        }

        // General optimization suggestions
        suggestions.append(contentsOf: [
            OptimizationSuggestion(
                category: "Startup",
                title: "Lazy Initialize Managers",
                description: "Consider lazy initialization for non-critical managers",
                priority: .low
            ),
            OptimizationSuggestion(
                category: "Performance",
                title: "Icon Caching",
                description: "Implement caching for frequently accessed app icons",
                priority: .medium
            ),
            OptimizationSuggestion(
                category: "UI",
                title: "Reduce Redraws",
                description: "Use @State and @Published more efficiently to minimize view redraws",
                priority: .low
            )
        ])

        return suggestions
    }
}

// MARK: - Performance Monitor View (for debugging)
struct PerformanceMonitorView: View {
    @StateObject private var optimizationManager = OptimizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Monitor")
                .font(.headline)

            HStack {
                Text("Memory:")
                Text(optimizationManager.memoryUsage)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("CPU:")
                Text(optimizationManager.cpuUsage)
                    .foregroundColor(.secondary)
            }

            Divider()

            if optimizationManager.isProfiling {
                Button("Stop Profiling") {
                    optimizationManager.stopProfiling()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Start Profiling") {
                    optimizationManager.startProfiling()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 250)
    }
}
