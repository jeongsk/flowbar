import SwiftUI

struct SettingsView: View {
    @State var modes: [Mode]
    let menuBarItems: [MenuBarItem]
    
    @State private var selectedMode: Mode?
    @State private var showingAddMode = false
    @State private var newModeName = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidebar: Mode list
            List(selection: $selectedMode) {
                ForEach(modes) { mode in
                    Label(mode.name, systemImage: mode.icon)
                        .tag(mode)
                }
                .onDelete(perform: deleteModes)
            }
            .navigationTitle("Modes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddMode = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMode) {
                AddModeSheet(name: $newModeName, onAdd: addMode)
            }
        } detail: {
            // Detail: Mode editor
            if let mode = selectedMode {
                ModeEditorView(mode: mode, menuBarItems: menuBarItems)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Select a mode")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Or create a new mode using the + button")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 900, height: 600)
    }
    
    private func addMode() {
        guard !newModeName.isEmpty else { return }
        
        // TODO: Add mode to ModeManager
        let newMode = Mode(name: newModeName)
        modes.append(newMode)
        selectedMode = newMode
        
        newModeName = ""
        showingAddMode = false
    }
    
    private func deleteModes(at offsets: IndexSet) {
        modes.remove(atOffsets: offsets)
        // TODO: Delete from ModeManager
    }
}

struct AddModeSheet: View {
    @Binding var name: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Mode")
                .font(.headline)
            
            TextField("Mode name", text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Add") {
                    onAdd()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding(24)
    }
}

#Preview {
    SettingsView(
        modes: Mode.defaultModes(),
        menuBarItems: []
    )
}
