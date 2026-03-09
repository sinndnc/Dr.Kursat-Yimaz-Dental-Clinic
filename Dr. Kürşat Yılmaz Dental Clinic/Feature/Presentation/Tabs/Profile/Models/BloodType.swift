import Foundation

let mockTreatments: [ToothTreatment] = [
    ToothTreatment(
        id: UUID(), toothNumber: 36, treatmentName: "İmplant Tedavisi",
        totalSessions: 4, completedSessions: 2, status: .active,
        startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
        estimatedEndDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
        doctorName: "Dr. Kürşat Yılmaz",
        notes: "Osseointegrasyon süreci devam ediyor",
        cost: 18500
    ),
    ToothTreatment(
        id: UUID(), toothNumber: 21, treatmentName: "Kanal Tedavisi",
        totalSessions: 3, completedSessions: 1, status: .active,
        startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        estimatedEndDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
        doctorName: "Dr. Kürşat Yılmaz",
        notes: nil, cost: 3200
    ),
    ToothTreatment(
        id: UUID(), toothNumber: nil, treatmentName: "Diş Beyazlatma",
        totalSessions: 6, completedSessions: 6, status: .completed,
        startDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
        estimatedEndDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()),
        doctorName: "Dr. Kürşat Yılmaz",
        notes: "Başarıyla tamamlandı", cost: 4500
    ),
    ToothTreatment(
        id: UUID(), toothNumber: 46, treatmentName: "Zirkonyum Kron",
        totalSessions: 3, completedSessions: 0, status: .planned,
        startDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
        estimatedEndDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
        doctorName: "Dr. Kürşat Yılmaz",
        notes: "Randevu bekleniyor", cost: 6800
    )
]

let mockPayments: [Payment] = [
    Payment(id: UUID(), date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, amount: 3500, method: .creditCard, status: .paid, description: "İmplant - 1. Taksit", invoiceNumber: "FTR-2024-0892"),
    Payment(id: UUID(), date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, amount: 3500, method: .creditCard, status: .paid, description: "İmplant - 2. Taksit", invoiceNumber: "FTR-2024-0756"),
    Payment(id: UUID(), date: Date(), amount: 3500, method: .bankTransfer, status: .pending, description: "İmplant - 3. Taksit", invoiceNumber: nil),
    Payment(id: UUID(), date: Calendar.current.date(byAdding: .day, value: -45, to: Date())!, amount: 1200, method: .cash, status: .paid, description: "Diş Temizliği", invoiceNumber: "FTR-2024-0612"),
    Payment(id: UUID(), date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, amount: 3200, method: .creditCard, status: .paid, description: "Kanal Tedavisi", invoiceNumber: "FTR-2024-0901")
]

let mockDocuments: [PatientDocument] = [
    PatientDocument(id: UUID(), title: "Panoramik Röntgen", type: .xray, date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, fileSize: "2.4 MB", thumbnailSystemImage: "xmark.circle"),
    PatientDocument(id: UUID(), title: "CBCT Tomografi", type: .tomography, date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, fileSize: "18.6 MB", thumbnailSystemImage: "cube"),
    PatientDocument(id: UUID(), title: "Tedavi Öncesi Fotoğraf", type: .photo, date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, fileSize: "3.1 MB", thumbnailSystemImage: "camera.fill"),
    PatientDocument(id: UUID(), title: "İmplant Onam Formu", type: .consent, date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, fileSize: "0.8 MB", thumbnailSystemImage: "doc.text.fill"),
    PatientDocument(id: UUID(), title: "Reçete - Amoksisilin", type: .prescription, date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, fileSize: "0.2 MB", thumbnailSystemImage: "pills.fill"),
    PatientDocument(id: UUID(), title: "Lab Sonucu - Kan Sayımı", type: .labResult, date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, fileSize: "0.5 MB", thumbnailSystemImage: "flask.fill")
]
