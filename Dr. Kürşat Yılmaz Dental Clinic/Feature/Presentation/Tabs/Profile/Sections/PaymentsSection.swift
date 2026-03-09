//
//  PaymentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//


import SwiftUI

// MARK: - Payments Section

struct PaymentsSection: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState

    var body: some View {
        VStack(spacing: 16) {
            KYSectionHeader(title: "Ödemelerim") {
                navState.navigate(to: .payments)
            }

            // Balance summary
            HStack(spacing: 10) {
                BalanceCard(
                    label: "Toplam Ödenen",
                    amount: vm.totalPaid,
                    color: .kyGreen,
                    icon: "checkmark.circle.fill"
                )
                BalanceCard(
                    label: "Bekleyen Borç",
                    amount: vm.totalDebt,
                    color: vm.totalDebt > 0 ? .kyDanger : .kyGreen,
                    icon: vm.totalDebt > 0 ? "exclamationmark.circle.fill" : "checkmark.circle.fill"
                )
            }
            .padding(.horizontal, 20)

            // Payment history
            VStack(alignment: .leading, spacing: 10) {
                Text("ÖDEME GEÇMİŞİ")
                    .font(.kyMono(9, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.kySubtext)
                    .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    ForEach(vm.payments.prefix(4)) { payment in
                        PaymentRow(payment: payment) {
                            navState.navigate(to: .paymentDetail(id: payment.id.uuidString))
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            if vm.payments.count > 4 {
                Button {
                    navState.navigate(to: .payments)
                } label: {
                    Text("Tüm ödemeleri gör (\(vm.payments.count))")
                        .font(.kySans(13, weight: .semibold))
                        .foregroundColor(.kyAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.kyAccent.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Balance Card

struct BalanceCard: View {
    let label: String
    let amount: Double
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.kyMono(9, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(.kySubtext)
                Text(amount.formatted_TRY)
                    .font(.kySerif(18, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Payment Row

struct PaymentRow: View {
    let payment: Payment
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.gray.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: methodIcon(for: payment.method))
                        .font(.system(size: 16))
//                        .foregroundColor(payment.statusColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(payment.description)
                        .font(.kySans(14, weight: .semibold))
                        .foregroundColor(.kyText)
                    Text(payment.date.kyFormatted)
                        .font(.kySans(12))
                        .foregroundColor(.kySubtext)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(payment.amount.formatted_TRY)
                        .font(.kySerif(16, weight: .bold))
                        .foregroundColor(.kyText)
                    KYBadge(text: payment.status.rawValue, color: .gray)
                }
            }
            .padding(14)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func methodIcon(for method: PaymentMethod) -> String {
        switch method {
        case .cash: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .bankTransfer: return "arrow.left.arrow.right.circle.fill"
        case .insurance: return "building.columns.fill"
        }
    }
}

// MARK: - Payment List View

struct PaymentListView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Ödemelerim")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Summary
                        HStack(spacing: 10) {
                            BalanceCard(label: "Toplam Ödenen", amount: vm.totalPaid, color: .kyGreen, icon: "checkmark.circle.fill")
                            BalanceCard(label: "Bekleyen Borç", amount: vm.totalDebt, color: vm.totalDebt > 0 ? .kyDanger : .kyGreen, icon: vm.totalDebt > 0 ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                        }
                        .padding(.horizontal, 20)

                        if vm.totalDebt > 0 {
                            ActionButton(title: "Ödeme Yap", icon: "creditcard.fill", color: .kyAccent, style: .filled) {}
                                .padding(.horizontal, 20)
                        }

                        VStack(spacing: 8) {
                            ForEach(vm.payments) { payment in
                                PaymentRow(payment: payment) {
                                    navState.navigate(to: .paymentDetail(id: payment.id.uuidString))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Payment Detail

struct PaymentDetailView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    let paymentId: String

    var payment: Payment? {
        vm.payments.first { $0.id.uuidString == paymentId }
    }

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Ödeme Detayı")

                if let p = payment {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Amount hero
                            VStack(spacing: 8) {
                                Text(p.amount.formatted_TRY)
                                    .font(.kySerif(44, weight: .bold))
                                    .foregroundColor(.kyText)
                                KYBadge(text: p.status.rawValue, color: .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
//                            .background(p.statusColor.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
//                                    .strokeBorder(p.statusColor.opacity(0.2), lineWidth: 1)
                            )

                            KYCard {
                                VStack(spacing: 14) {
                                    KYDetailRow(icon: "doc.text.fill", label: "Açıklama", value: p.description, iconColor: .kyAccent)
                                    KYDivider()
                                    KYDetailRow(icon: "calendar", label: "Tarih", value: p.date.kyFormatted, iconColor: .kyBlue)
                                    KYDivider()
                                    KYDetailRow(icon: paymentMethodIcon(for: p.method), label: "Ödeme Yöntemi", value: p.method.rawValue, iconColor: .kyGreen)
                                    if let invoice = p.invoiceNumber {
                                        KYDivider()
                                        KYDetailRow(icon: "number.circle.fill", label: "Fatura No", value: invoice, iconColor: .kySubtext)
                                    }
                                }
                            }

                            if p.invoiceNumber != nil {
                                ActionButton(title: "Faturayı İndir", icon: "arrow.down.circle.fill", color: .kyBlue, style: .filled) {}
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    func paymentMethodIcon(for method: PaymentMethod) -> String {
        switch method {
        case .cash: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .bankTransfer: return "arrow.left.arrow.right.circle.fill"
        case .insurance: return "building.columns.fill"
        }
    }
}
