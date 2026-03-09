import SwiftUI

// MARK: - Design System Extensions

extension Color {
    static let kyBackground = Color(red: 0.06, green: 0.06, blue: 0.08)
    static let kySurface = Color(red: 0.11, green: 0.11, blue: 0.14)
    static let kyCard = Color(red: 0.14, green: 0.14, blue: 0.18)
    static let kyCardElevated = Color(red: 0.17, green: 0.17, blue: 0.22)
    static let kyBorder = Color.white.opacity(0.07)
    static let kyBorderSubtle = Color.white.opacity(0.04)
    static let kyText = Color(red: 0.95, green: 0.94, blue: 0.92)
    static let kySubtext = Color(red: 0.6, green: 0.58, blue: 0.55)
    static let kyAccent = Color(red: 0.82, green: 0.72, blue: 0.5)
    static let kyAccentDark = Color(red: 0.75, green: 0.60, blue: 0.35)
    static let kyDanger = Color(red: 0.85, green: 0.35, blue: 0.35)
    static let kyGreen = Color(red: 0.38, green: 0.78, blue: 0.50)
    static let kyBlue = Color(red: 0.30, green: 0.60, blue: 0.90)
    static let kyOrange = Color(red: 0.95, green: 0.65, blue: 0.20)
    static let kyPurple = Color(red: 0.60, green: 0.40, blue: 0.80)
}

// MARK: - Typography

extension Font {
    static func kySerif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func kyMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
    static func kySans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - KYSectionHeader

struct KYSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String = "Tümü"

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.kyMono(10, weight: .bold))
                    .tracking(2.5)
                    .foregroundColor(.kySubtext)
                if let subtitle {
                    Text(subtitle)
                        .font(.kySans(13))
                        .foregroundColor(.kySubtext.opacity(0.7))
                }
            }
            Spacer()
            if let action {
                Button(action: action) {
                    HStack(spacing: 3) {
                        Text(actionLabel)
                            .font(.kySans(12, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.kyAccent)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - KYCard

struct KYCard<Content: View>: View {
    let content: () -> Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 18
    var glowColor: Color? = nil

    init(padding: CGFloat = 16, cornerRadius: CGFloat = 18, glowColor: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        glowColor != nil ? glowColor!.opacity(0.25) : Color.kyBorder,
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - KYBadge

struct KYBadge: View {
    let text: String
    let color: Color
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
            }
            Text(text)
                .font(.kyMono(10, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - KYProgressBar

struct KYProgressBar: View {
    let progress: Double
    let color: Color
    var height: CGFloat = 6
    var showLabel: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(.kyMono(10, weight: .semibold))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.kySurface)
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * min(1.0, progress)))
                }
            }
            .frame(height: height)
        }
    }
}

// MARK: - KYDetailRow

struct KYDetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .kyText
    var iconColor: Color = .kySubtext

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(iconColor)
            }
            Text(label)
                .font(.kySans(14))
                .foregroundColor(.kySubtext)
            Spacer()
            Text(value)
                .font(.kySans(14, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - KYNavigationRow

struct KYNavigationRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconBg: Color = .kyAccent
    var badge: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconBg.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconBg)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.kySans(15, weight: .semibold))
                        .foregroundColor(.kyText)
                    if let subtitle {
                        Text(subtitle)
                            .font(.kySans(12))
                            .foregroundColor(.kySubtext)
                    }
                }

                Spacer()

                if let badge {
                    KYBadge(text: badge, color: .kyDanger)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.kySubtext.opacity(0.4))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - KYDivider

struct KYDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.kyBorder)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
}

// MARK: - KYEmptyState

struct KYEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionLabel: String = ""

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.kyAccent.opacity(0.08))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.kyAccent.opacity(0.6))
            }
            VStack(spacing: 6) {
                Text(title)
                    .font(.kySerif(17, weight: .bold))
                    .foregroundColor(.kyText)
                Text(message)
                    .font(.kySans(13))
                    .foregroundColor(.kySubtext)
                    .multilineTextAlignment(.center)
            }
            if let action, !actionLabel.isEmpty {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.kySans(14, weight: .semibold))
                        .foregroundColor(.kyBackground)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.kyAccent)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(32)
    }
}

// MARK: - KYDetailHeader (for detail pages)

struct KYDetailHeader: View {
    let title: String
    var subtitle: String? = nil
    var dismiss: (() -> Void)? = nil

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            HStack {
                Button {
                    if let dismiss { dismiss() }
                    else { presentationMode.wrappedValue.dismiss() }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.kyCard)
                            .frame(width: 38, height: 38)
                            .overlay(Circle().strokeBorder(Color.kyBorder, lineWidth: 1))
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.kyText)
                    }
                }
                Spacer()
            }
            VStack(spacing: 2) {
                Text(title)
                    .font(.kySerif(17, weight: .bold))
                    .foregroundColor(.kyText)
                if let subtitle {
                    Text(subtitle)
                        .font(.kySans(12))
                        .foregroundColor(.kySubtext)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

extension Double {
    var formatted_TRY: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "₺"
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "tr_TR")
        return f.string(from: NSNumber(value: self)) ?? "₺\(Int(self))"
    }
}

// MARK: - Date Formatters

extension Date {
    var kyFormatted: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: self)
    }

    var kyFormattedWithTime: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM yyyy, HH:mm"
        return f.string(from: self)
    }

    var kyRelative: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
        if days == 0 { return "Bugün" }
        if days == 1 { return "Yarın" }
        if days == -1 { return "Dün" }
        if days > 1 { return "\(days) gün sonra" }
        return "\(-days) gün önce"
    }
}


extension TreatmentStatus {
    var uiColor: Color {
        switch self {
        case .active:    return .kyGreen
        case .planned:   return .kyBlue
        case .completed: return .kyAccent
        case .pending:   return .kyOrange
        }
    }
}

extension PaymentStatus {
    var uiColor: Color {
        switch self {
        case .paid:    return .kyGreen
        case .pending: return .kyOrange
        case .overdue: return .kyDanger
        case .partial: return .kyBlue
        }
    }
}

extension Allergy.AllergySeverity {
    var uiColor: Color {
        switch self {
        case .mild:     return .kyGreen
        case .moderate: return .kyOrange
        case .severe:   return .kyDanger
        }
    }
}
