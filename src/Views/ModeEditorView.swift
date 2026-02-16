import SwiftUI

struct ModeEditorView: View {
    @Bindable var mode: Mode
    let menuBarItems: [MenuBarItem]
    
    @State private var showingIconPicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: mode.icon)
                        .font(.title)
                        .frame(width: 44, height: 44)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            showingIconPicker = true
                        }
                    
                    VStack(alignment: .leading) {
                        Text(mode.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Created \(mode.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // General settings
                GroupBox("General") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Mode name", text: $mode.name)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                        }
                        
                        HStack {
                            Text("Keyboard Shortcut")
                            Spacer()
                            TextField("Shortcut", text: $mode.keyboardShortcut ?? "")
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                            
                            Text("⌘⇧ + key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Menu Bar Items
                GroupBox("Menu Bar Items") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select which items to show in this mode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if menuBarItems.isEmpty {
                            Text("No menu bar items detected")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 8) {
                                ForEach(menuBarItems) { item in
                                    Toggle(item.displayName, isOn: Binding(
                                        get: { mode.visibleItemIds.contains(item.id) },
                                        set: { isVisible in
                                            if isVisible {
                                                mode.visibleItemIds.append(item.id)
                                            } else {
                                                mode.visibleItemIds.removeAll { $0 == item.id }
                                            }
                                        }
                                    ))
                                    .toggleStyle(.checkbox)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                
                // Focus Guard
                GroupBox("Focus Guard") {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Enable Focus Guard", isOn: $mode.focusGuardEnabled)
                        
                        Text("Prevents apps from stealing keyboard focus while this mode is active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Apps to Launch
                GroupBox("Launch Apps") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Automatically launch these apps when switching to this mode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(mode.launchAppBundleIds, id: \.self) { bundleId in
                            HStack {
                                if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
                                    Text(app.localizedName ?? bundleId)
                                } else {
                                    Text(bundleId)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    mode.launchAppBundleIds.removeAll { $0 == bundleId }
                                }) {
                                    Image(systemName: "minus.circle")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Button("Add App...") {
                            // TODO: Show app picker
                        }
                    }
                    .padding()
                }
                
                // Blocked Apps
                if mode.focusGuardEnabled {
                    GroupBox("Blocked Apps") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Apps to block while in this mode")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(mode.blockedAppBundleIds, id: \.self) { bundleId in
                                HStack {
                                    Text(bundleId)
                                    Spacer()
                                    Button(action: {
                                        mode.blockedAppBundleIds.removeAll { $0 == bundleId }
                                    }) {
                                        Image(systemName: "minus.circle")
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            Button("Add App to Block...") {
                                // TODO: Show app picker
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $mode.icon)
        }
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    let icons = [
        "circle.grid.2x2",
        "chevron.left.forwardslash.chevron.right",
        "paintbrush.pointed",
        "video",
        "brain.head.profile",
        "gearshape",
        "star",
        "bolt",
        "moon",
        "sun.max",
        "book",
        "music.note",
        "gamecontroller",
        "cup.and.saucer",
        "briefcase",
        "house"
    ]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Icon")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(icons, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                        dismiss()
                    }) {
                        Image(systemName: icon)
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedIcon == icon ? Color.accentColor : Color.secondary.opacity(0.2))
                            )
                            .foregroundColor(selectedIcon == icon ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button("Cancel") {
                dismiss()
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}

#Preview {
    ModeEditorView(
        mode: Mode(name: "Coding"),
        menuBarItems: []
    )
}
