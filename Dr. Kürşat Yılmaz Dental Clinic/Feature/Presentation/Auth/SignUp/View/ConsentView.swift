import SwiftUI

// MARK: - KVKK Rıza Ekranı
struct ConsentView: View {

    // Tüm kutucuklar başta işaretsiz — KVKK gereği önceden seçili olamaz
    @State private var identityConsent = false
    @State private var contactConsent  = false
    @State private var healthConsent   = false
    @State private var showAlert       = false
    @State private var alertMessage    = ""

    // Sheet kontrolü — hangi sayfa açılacak
    @State private var showingSheet    = false
    @State private var activeSheet: ConsentSheetType? = nil

    /// Rıza tamamlandığında çağrılır
    var onConsentCompleted: () -> Void

    // Zorunlu rızaların tamamı verildi mi?
    private var canProceed: Bool {
        identityConsent && contactConsent && healthConsent
    }

    // Hangi onay kutucuğunun sheet'i açık — sheet kapanınca bu set edilir
    private func binding(for type: ConsentSheetType) -> Binding<Bool> {
        switch type {
        case .privacy:    return $identityConsent
        case .kvkk:       return $contactConsent
        case .terms:      return $healthConsent
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Başlık
                    headerSection

                    Divider()

                    // Aydınlatma Metni
                    enlightenmentSection

                    Divider()

                    // Rıza Kutucukları
                    consentCheckboxes

                    Divider()

                    // Linkler
                    linksSection

                    // Onay Butonu
                    approveButton

                    // Reddetme linki
                    rejectButton
                }
                .padding()
            }
            .navigationTitle("Kişisel Veri Rızası")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(item: $activeSheet) { sheetType in
            ConsentDocumentSheet(type: sheetType) {  _ in
                // Kullanıcı sheet içinde "Okudum, Onaylıyorum" dedi → checkmark işaretle
                withAnimation(.spring(response: 0.3)) {
                    binding(for: sheetType).wrappedValue = true
                }
            }
        }
    }

    // MARK: - Alt Görünümler

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("KVKK Kapsamında Bilgilendirme", systemImage: "lock.shield.fill")
                .font(.headline)
                .foregroundColor(.accentColor)

            Text("Kliniğimiz tarafından sunulan hizmetlerden yararlanabilmeniz için aşağıdaki kişisel verilerinizin işlenmesine ilişkin açık rızanızı talep etmekteyiz.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var enlightenmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("İşlenen Veriler ve Amaçları")
                .font(.subheadline)
                .bold()

            dataRow(
                icon: "person.text.rectangle",
                title: "Kimlik Verisi",
                detail: "Adınız, soyadınız ve TC kimlik numaranız; hasta kaydı oluşturmak ve kimlik doğrulama amacıyla işlenmektedir.",
                color: .blue
            )
            dataRow(
                icon: "envelope",
                title: "İletişim Verisi",
                detail: "Telefon numaranız ve e-posta adresiniz; randevu bildirimleri ve acil durum iletişimi amacıyla işlenmektedir.",
                color: .green
            )
            dataRow(
                icon: "cross.case",
                title: "Sağlık Verisi (Özel Nitelikli)",
                detail: "Tanı, ilaç, reçete ve tahlil bilgileriniz; tıbbi hizmet sunumu ve hasta takibi amacıyla işlenmektedir. Bu veriler üçüncü kişilerle paylaşılmaz.",
                color: .red
            )
        }
    }

    private var consentCheckboxes: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Açık Rıza Beyanları")
                .font(.subheadline)
                .bold()

            consentRow(
                isOn: $identityConsent,
                text: "Kimlik verilerimin (ad, soyad, TC kimlik no) hasta kaydı oluşturma amacıyla işlenmesine **açıkça rıza veriyorum.**",
                sheetType: .privacy
            )
            consentRow(
                isOn: $contactConsent,
                text: "İletişim verilerimin (telefon, e-posta) randevu bildirimi ve acil iletişim amacıyla işlenmesine **açıkça rıza veriyorum.**",
                sheetType: .kvkk
            )
            consentRow(
                isOn: $healthConsent,
                text: "Sağlık verilerimin (tanı, ilaç, reçete, tahlil) tıbbi hizmet sunumu amacıyla işlenmesine **açıkça rıza veriyorum.**",
                sheetType: .terms,
                highlighted: true
            )
        }
    }

    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Link("📄 Gizlilik Politikasını Oku", destination: ConsentConfig.privacyPolicyURL)
                .font(.footnote)
            Link("📋 KVKK Aydınlatma Metnini Oku", destination: ConsentConfig.kvkkURL)
                .font(.footnote)
        }
    }

    private var approveButton: some View {
        Button(action: handleApprove) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                Text("Rızamı Onaylıyorum")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canProceed ? Color.accentColor : Color.gray.opacity(0.3))
            .foregroundColor(canProceed ? .white : .gray)
            .cornerRadius(12)
        }
        .disabled(!canProceed)
    }

    private var rejectButton: some View {
        Button(action: handleReject) {
            Text("Rıza vermiyorum, uygulamaya devam etmek istemiyorum")
                .font(.footnote)
                .foregroundColor(.secondary)
                .underline()
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom)
    }

    // MARK: - Yardımcı Görünümler

    private func dataRow(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.footnote).bold()
                Text(detail).font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private func consentRow(
        isOn: Binding<Bool>,
        text: String,
        sheetType: ConsentSheetType,
        highlighted: Bool = false
    ) -> some View {
        Button {
            if isOn.wrappedValue {
                // Zaten onaylıysa toggle ile geri al
                withAnimation(.spring(response: 0.3)) {
                    isOn.wrappedValue = false
                }
            } else {
                // Onaylı değilse önce sayfayı aç
                activeSheet = sheetType
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isOn.wrappedValue ? Color.kyAccent : Color.kyCard)
                        .frame(width: 20, height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(
                                    isOn.wrappedValue ? Color.clear : Color.kyBorder,
                                    lineWidth: 1
                                )
                        )

                    if isOn.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.kyBackground)
                    }
                }

                // Metin
                VStack(alignment: .leading, spacing: 2) {
                    Text(.init(text))
                        .font(.kySans(13))
                        .foregroundColor(.kySubtext)
                        .multilineTextAlignment(.leading)

                    Text("* Zorunlu")
                        .font(.caption2)
                        .foregroundColor(highlighted ? .red : .orange)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    // MARK: - Aksiyonlar

    private func handleApprove() {
        guard canProceed else {
            alertMessage = "Lütfen tüm zorunlu rıza kutucuklarını işaretleyiniz."
            showAlert = true
            return
        }

        let record = ConsentRecord(
            userId: "anonymous",        // Gerçek userId'yi buraya ver
            identityConsent: identityConsent,
            contactConsent: contactConsent,
            healthConsent: healthConsent
        )

        ConsentManager.shared.saveConsent(record)
        onConsentCompleted()
    }

    private func handleReject() {
        alertMessage = "Rıza vermemeniz durumunda uygulamamızı kullanamazsınız. Uygulamadan çıkılacaktır."
        showAlert = true
        // İsteğe bağlı: uygulamadan çık
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2) { exit(0) }
    }
}
