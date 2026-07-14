import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CastListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BCTheme.accent)
    }
}

struct CastListView: View {
    @EnvironmentObject private var store: BatchCastStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Cast?

    var body: some View {
        NavigationStack {
            ZStack {
                BCTheme.backdrop.ignoresSafeArea()
                if store.casts.isEmpty {
                    ContentUnavailableView("No Casts Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.casts) { item in
                            CastRow(item: item)
                                .listRowBackground(BCTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteCast(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Cast")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addCastButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                CastFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                CastFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct CastRow: View {
    let item: Cast

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.pieceName)
                .font(BCTheme.headlineFont)
                .foregroundStyle(BCTheme.ink)
            Text(String(describing: item.metalType))
                .font(.caption)
                .foregroundStyle(BCTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum CastFormMode: Identifiable {
    case add
    case edit(Cast)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct CastFormView: View {
    @EnvironmentObject private var store: BatchCastStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: CastFormMode

    @State private var draftPieceName: String = ""
    @State private var draftMetalType: String = ""
    @State private var draftWeightGrams: String = ""
    @State private var draftBurnoutSchedule: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BCTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Piece", text: $draftPieceName)
                    .accessibilityIdentifier("pieceNameField")
                Picker("Metal Type", selection: $draftMetalType) {
                    ForEach(BCMetalTypeOption.all, id: \.self) { Text($0) }
                }
                TextField("Weight (g)", text: $draftWeightGrams)
                    .accessibilityIdentifier("weightGramsField")
                TextField("Burnout Schedule", text: $draftBurnoutSchedule)
                    .accessibilityIdentifier("burnoutScheduleField")
                    }
                    .listRowBackground(BCTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("castSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftPieceName = item.pieceName
        draftMetalType = item.metalType
        draftWeightGrams = item.weightGrams
        draftBurnoutSchedule = item.burnoutSchedule
        } else {
        draftPieceName = ""
        draftMetalType = ""
        draftWeightGrams = ""
        draftBurnoutSchedule = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addCast(pieceName: draftPieceName, metalType: draftMetalType, weightGrams: draftWeightGrams, burnoutSchedule: draftBurnoutSchedule, isPro: purchases.isPro)
        case .edit(let item):
            store.updateCast(item.id, pieceName: draftPieceName, metalType: draftMetalType, weightGrams: draftWeightGrams, burnoutSchedule: draftBurnoutSchedule)
        }
        BCHaptics.success()
        dismiss()
    }
}
