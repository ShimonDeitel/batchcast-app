import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var purchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                BCTheme.backdrop.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(BCTheme.accent)
                        .padding(.top, 40)

                    Text("Batch Cast Pro")
                        .font(BCTheme.titleFont)
                        .foregroundStyle(BCTheme.ink)

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow("infinity", "Unlimited entries")
                        featureRow("star.fill", "Metal Weight & Cost Calculator")
                        featureRow("checkmark.seal.fill", "Estimate cost by karat, metal type, and entered market price.")
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    Button {
                        purchasing = true
                        Task {
                            await purchases.purchase()
                            purchasing = false
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        HStack {
                            if purchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(purchases.product.map { "Subscribe for \($0.displayPrice)/mo" } ?? "Unlock Pro")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BCTheme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(purchasing || purchases.product == nil)
                    .padding(.horizontal, 24)
                    .accessibilityIdentifier("paywallSubscribeButton")

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(.footnote)
                    .foregroundStyle(BCTheme.inkFaded)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(BCTheme.accent)
                .frame(width: 24)
            Text(text)
                .foregroundStyle(BCTheme.ink)
            Spacer()
        }
    }
}
