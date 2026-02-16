import SwiftUI

struct ModePickerView: View {
    let modes: [Mode]
    let currentMode: Mode?
    let onSelectMode: (Mode) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredModes: [Mode] {
        if searchText.isEmpty {
            return modes
        }
        return modes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search modes...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Mode list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredModes) { mode in
                        ModeRow(
                            mode: mode,
                            isSelected: currentMode?.id == mode.id,
                            onSelect: { onSelectMode(mode) }
                        )
                    }
                }
                .padding(8)
            }
            
            Divider()
            
            // Footer
            HStack {
                Text("\(modes.count) modes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Settings") {
                    // Open settings
                    NSApp.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 280)
    }
}

struct ModeRow: View {
    let mode: Mode
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: mode.icon)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                    )
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Name and info
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let shortcut = mode.keyboardShortcut {
                        Text("⌘⇧\(shortcut)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ModePickerView(
        modes: Mode.defaultModes(),
        currentMode: Mode.defaultModes().first,
        onSelect: { _ in }
    )
}
