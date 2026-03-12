//
//  PrivacyPolicyView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Gizlilik Politikası")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        KYBadge(text: "KVKK Uyumlu", color: .kyGreen, icon: "checkmark.shield.fill")

                        VStack(alignment: .leading, spacing: 12) {
                            policySection(title: "Kişisel Verilerin Korunması",
                                body: "KY Klinik olarak 6698 sayılı KVKK kapsamında kişisel verileriniz güvence altındadır. Sağlık verileriniz yalnızca tedavi amaçlı kullanılmaktadır.")
                            policySection(title: "Veri Saklama",
                                body: "Hasta kayıtları yasal süre olan 5 yıl boyunca güvenli sunucularda saklanmaktadır.")
                            policySection(title: "Veri Haklarınız",
                                body: "Verilerinize erişme, düzeltme ve silme hakkına sahipsiniz. Talep için info@kyclinic.com adresine başvurabilirsiniz.")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    func policySection(title: String, body: String) -> some View {
        KYCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.kySans(15, weight: .bold))
                    .foregroundColor(.kyText)
                Text(body)
                    .font(.kySans(13))
                    .foregroundColor(.kySubtext)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
