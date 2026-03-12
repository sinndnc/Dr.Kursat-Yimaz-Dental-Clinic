//
//  PrivacyPolicyView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//
import SwiftUI

struct PrivacyPolicyView: View {
    
    private let policyURL = URL(string: "https://indigo-egret-2c6.notion.site/Privacy-Policy-32101f2ea2468070a5d2eb6284a292ae")!
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                KYDetailHeader(title: "Gizlilik Politikası")
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        KYBadge(
                            text: "KVKK Uyumlu",
                            color: .kyGreen,
                            icon: "checkmark.shield.fill"
                        )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            policySection(
                                title: "Kişisel Verilerin Korunması",
                                body: "KY Klinik olarak 6698 sayılı KVKK kapsamında kişisel verileriniz korunmaktadır. Sağlık verileriniz yalnızca tedavi süreçlerinin yürütülmesi amacıyla işlenir ve yetkisiz kişilerle paylaşılmaz."
                            )
                            
                            policySection(
                                title: "Toplanan Veriler",
                                body: "Uygulama kapsamında ad, soyad, telefon numarası, doğum tarihi ve randevu bilgileri gibi veriler toplanabilir. Bu bilgiler yalnızca hasta yönetimi ve randevu işlemleri için kullanılır."
                            )
                            
                            policySection(
                                title: "Veri Saklama",
                                body: "Hasta kayıtları ilgili sağlık mevzuatı doğrultusunda güvenli sunucularda saklanır ve gerekli yasal süre boyunca muhafaza edilir."
                            )
                            
                            policySection(
                                title: "Veri Haklarınız",
                                body: "KVKK kapsamında verilerinize erişme, düzeltme veya silinmesini talep etme hakkına sahipsiniz. Talepleriniz için info@kyclinic.com adresine başvurabilirsiniz."
                            )
                        }
                        
                        Divider()
                        
                        VStack(spacing: 10) {
                            
                            Text("Detaylı gizlilik politikası için web sayfamızı ziyaret edebilirsiniz.")
                                .font(.kySans(13))
                                .foregroundColor(.kySubtext)
                            
                            Link(destination: policyURL) {
                                HStack {
                                    Image(systemName: "safari")
                                    Text("Tam Gizlilik Politikasını Aç")
                                }
                                .font(.kySans(14, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.kyAccent)
                                .cornerRadius(12)
                            }
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
