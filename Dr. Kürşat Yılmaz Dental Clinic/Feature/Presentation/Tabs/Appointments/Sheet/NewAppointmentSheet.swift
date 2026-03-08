////
////  NewAppointmentSheet.swift
////  Dr. Kürşat Yılmaz Dental Clinic
////
////  Created by Sinan Dinç on 3/7/26.
////
//
//import SwiftUI
//
//struct NewAppointmentSheet: View {
//    
//    @Environment(\.dismiss) private var dismiss
//    @State private var selectedTreatment = ""
//    @State private var selectedDate = Date()
//    @State private var notes = ""
//    
//    private let treatments = [
//        "EMS / GBT Diş Temizliği", "Lamina Kaplama", "Kompozit Gülüş Tasarımı",
//        "Dental İmplant", "Şeffaf Plak (Aligner)", "3D Tarama & Planlama",
//        "Dolgu & Koruyucu Uygulama", "Onlay & Overlay Restorasyon"
//    ]
//    
//    var body: some View {
//        ZStack {
//            Color.kyBackground.ignoresSafeArea()
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 28) {
//                    // Header
//                    VStack(alignment: .leading, spacing: 6) {
//                        HStack(spacing: 5) {
//                            Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
//                            Text("YENİ RANDEVU")
//                                .font(.system(size: 10, weight: .bold, design: .monospaced))
//                                .tracking(3)
//                                .foregroundColor(Color.kyAccent)
//                        }
//                        Text("Randevu Planla")
//                            .font(.system(size: 28, weight: .bold, design: .serif))
//                            .foregroundColor(Color.kyText)
//                        Text("Aşağıdaki formu doldurun, en kısa\nsürede sizi arayalım.")
//                            .font(.system(size: 14))
//                            .foregroundColor(Color.kySubtext)
//                            .lineSpacing(3)
//                    }
//                    .padding(.top, 8)
//                    
//                    // Treatment Picker
//                    VStack(alignment: .leading, spacing: 10) {
//                        FormLabel(text: "TEDAVİ SEÇİN")
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 8) {
//                                ForEach(treatments, id: \.self) { t in
//                                    Button {
//                                        withAnimation(.spring(response: 0.28)) {
//                                            selectedTreatment = t
//                                        }
//                                    } label: {
//                                        Text(t)
//                                            .font(.system(size: 12, weight: .semibold))
//                                            .foregroundColor(selectedTreatment == t ? Color.kyBackground : Color.kySubtext)
//                                            .padding(.horizontal, 14)
//                                            .padding(.vertical, 9)
//                                            .background(
//                                                selectedTreatment == t
//                                                ? AnyView(LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing))
//                                                : AnyView(Color.kyCard)
//                                            )
//                                            .clipShape(Capsule())
//                                            .overlay(
//                                                selectedTreatment == t ? nil :
//                                                Capsule().strokeBorder(Color.kyBorder, lineWidth: 1)
//                                            )
//                                    }
//                                    .buttonStyle(ScaleButtonStyle())
//                                }
//                            }
//                            .padding(.horizontal, 1)
//                            .padding(.vertical, 2)
//                        }
//                    }
//                    // Date Picker
//                    VStack(alignment: .leading, spacing: 10) {
//                        FormLabel(text: "TARİH & SAAT")
//                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date ])
//                            .datePickerStyle(.graphical)
//                            .labelsHidden()
//                            .colorScheme(.dark)
//                            .padding(14)
//                            .background(Color.kyCard)
//                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                    .strokeBorder(Color.kyBorder, lineWidth: 1)
//                            )
//                        
//                        DatePicker("Select Hour:", selection: $selectedDate, in: Date()..., displayedComponents: [.hourAndMinute])
//                            .font(.subheadline)
//                            .fontWeight(.medium)
//                            .datePickerStyle(.compact)
//                            .colorScheme(.dark)
//                            .padding(14)
//                            .background(Color.kyCard)
//                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                    .strokeBorder(Color.kyBorder, lineWidth: 1)
//                            )
//                    }
//                    
//                    // Notes
//                    VStack(alignment: .leading, spacing: 10) {
//                        FormLabel(text: "NOTLAR (İSTEĞE BAĞLI)")
//                        ZStack(alignment: .topLeading) {
//                            if notes.isEmpty {
//                                Text("Eklemek istediğiniz bir not var mı?")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(Color.kySubtext.opacity(0.5))
//                                    .padding(.horizontal, 14)
//                                    .padding(.top, 14)
//                            }
//                            TextEditor(text: $notes)
//                                .font(.system(size: 14))
//                                .foregroundColor(Color.kyText)
//                                .scrollContentBackground(.hidden)
//                                .frame(minHeight: 90)
//                                .padding(10)
//                        }
//                        .background(Color.kyCard)
//                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                .strokeBorder(Color.kyBorder, lineWidth: 1)
//                        )
//                    }
//                    // Submit
//                    Button { dismiss() } label: {
//                        HStack(spacing: 8) {
//                            Spacer()
//                            Image(systemName: "calendar.badge.plus")
//                                .font(.system(size: 14, weight: .bold))
//                            Text("Randevu Talebi Gönder")
//                                .font(.system(size: 16, weight: .bold))
//                            Spacer()
//                        }
//                        .foregroundColor(Color.kyBackground)
//                        .padding(.vertical, 16)
//                        .background(
//                            LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing)
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                        .shadow(color: Color.kyAccent.opacity(0.3), radius: 12, x: 0, y: 5)
//                    }
//                    .buttonStyle(ScaleButtonStyle())
//                    .padding(.bottom, 40)
//                }
//                .padding(.horizontal, 24)
//            }
//            // Dismiss
//            HStack {
//                Spacer()
//                Button { dismiss() } label: {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 12, weight: .bold))
//                        .foregroundColor(Color.kySubtext)
//                        .padding(10)
//                        .background(Color.kySurface)
//                        .clipShape(Circle())
//                }
//                .padding(.trailing, 20)
//                .padding(.top, 16)
//            }
//            .frame(maxHeight: .infinity, alignment: .top)
//        }
//        .padding(.vertical)
//        .presentationDetents([.large])
//        .presentationDragIndicator(.visible)
//        .presentationBackground(Color.kyBackground)
//    }
//    
//}
