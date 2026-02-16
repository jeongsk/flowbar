import SwiftUI

struct ModeSwitcherView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var modeManager: ModeManager

    init() {
        // Temporary placeholder - will be injected properly
        _modeManager = State(initialValue: ModeManager(modelContext: DataController.shared.modelContext))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Select Mode")
                .font(.headline)

            ForEach(modeManager.allModes) { mode in
                ModeButton(
                    mode: mode,
                    isSelected: modeManager.currentMode?.id == mode.id
                ) {
                    modeManager.switchToMode(mode)
                }
            }
        }
        .padding()
    }
}

struct ModeButton: View {
    let mode: Mode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = mode.icon {
                    Image(systemName: icon)
                }
                Text(mode.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ModeSwitcherView()
}
