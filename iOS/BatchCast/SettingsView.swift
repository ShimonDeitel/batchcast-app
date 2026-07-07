import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchCastStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchcast_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchcast_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BCTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BCTheme.accent)
                                Text("Batch Cast Pro active")
                                    .foregroundStyle(BCTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BCTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BCTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BCTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BCTheme.card)

                    if purchases.isPro {
                        Section("Metal Weight & Cost Calculator") {
                            Text("Estimate cost by karat, metal type, and entered market price.")
                                .font(.caption)
                                .foregroundStyle(BCTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.metalType)
                                        .foregroundStyle(BCTheme.ink)
                                    Spacer()
                                    Text(p.weightGrams)
                                        .font(.caption)
                                        .foregroundStyle(BCTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BCTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BCHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BCTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddCastButton")
                    }
                    .listRowBackground(BCTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchcast-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchcast-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BCTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BCTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                CastFormView(mode: .add)
            }
        }
    }
}
