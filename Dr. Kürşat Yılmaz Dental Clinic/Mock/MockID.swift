// MARK: - MockData.swift
// Realistic mock data for all models.
// All IDs are real UUID strings — stable, unique, and safe for Firestore.

import Foundation

// MARK: - Stable Mock IDs (real UUIDs, generated once, never change)
enum MockID {
    // Clinics
    static let clinicAtasehir = "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
    static let clinicKadikoy  = "B2C3D4E5-F6A7-8901-BCDE-F12345678901"
    
    // Doctors
    static let doctorYilmaz   = "PAQ6wtbFbkeGUHtq2Izfc3H2uDE3"
    static let doctorDemir    = "D4E5F6A7-B8C9-0123-DEF0-234567890123"
    static let doctorArslan   = "E5F6A7B8-C9D0-1234-EF01-345678901234"
    static let doctorSahin    = "F6A7B8C9-D0E1-2345-F012-456789012345"
    
    // Patients
    static let patientSinan    = "7a9b2fe0-3ad7-472d-89fa-7bb98b3dbe67"
    static let patientCelik   = "B8C9D0E1-F2A3-4567-1234-678901234567"
    static let patientAydin   = "C9D0E1F2-A3B4-5678-2345-789012345678"
    static let patientOzturk  = "D0E1F2A3-B4C5-6789-3456-890123456789"
    static let patientYildiz  = "E1F2A3B4-C5D6-7890-4567-901234567890"
    
    
    // Aesthetic
    static let lamina            = "11A2B3C4-D5E6-7890-ABCD-EF1234560001"
    static let kompozitGulüs     = "22A2B3C4-D5E6-7890-ABCD-EF1234560002"
    static let klinik3DUretim    = "33A2B3C4-D5E6-7890-ABCD-EF1234560003"
    
    // Restorative
    static let onlayOverlay      = "44A2B3C4-D5E6-7890-ABCD-EF1234560004"
    static let implantProtetik   = "55A2B3C4-D5E6-7890-ABCD-EF1234560005"
    static let dolguKoruyucu     = "66A2B3C4-D5E6-7890-ABCD-EF1234560006"
    static let taramaPlanlama    = "77A2B3C4-D5E6-7890-ABCD-EF1234560007"
    static let emsTemizlik       = "88A2B3C4-D5E6-7890-ABCD-EF1234560008"
    static let seffafPlak        = "99A2B3C4-D5E6-7890-ABCD-EF1234560009"
        
    // Appointments
    static let appt001 = "F8A9B0C1-D2E3-4567-1234-678901234567"
    static let appt002 = "A9B0C1D2-E3F4-5678-2345-789012345678"
    static let appt003 = "B0C1D2E3-F4A5-6789-3456-890123456789"
    static let appt004 = "C1D2E3F4-A5B6-7890-4567-901234567890"
    static let appt005 = "D2E3F4A5-B6C7-8901-5678-012345678901"
    static let appt006 = "E3F4A5B6-C7D8-9012-6789-123456789012"
}

// MARK: - Date helper
private extension Date {
    static func make(year: Int, month: Int, day: Int,
                     hour: Int = 9, minute: Int = 0) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = hour; c.minute = minute
        return Calendar.current.date(from: c) ?? Date()
    }
}


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


// =========================================================================
// MARK: - MockClinics
// =========================================================================
enum MockClinics {

    static let atasehir = Clinic(
        id: MockID.clinicAtasehir,
        name: "Bana Dental Clinic – Ataşehir",
        branchCode: "ATA-01",
        address: ClinicAddress(
            city: "İstanbul",
            district: "Ataşehir",
            neighborhood: "Yenisahra Mah.",
            street: "Küçükbakkalköy Cad.",
            buildingNo: "14",
            apartmentNo: "3",
            postalCode: "34750",
            latitude: 40.9923,
            longitude: 29.1244
        ),
        phone: "+90 216 555 10 10",
        email: "atasehir@banadental.com",
        website: "https://banadental.com",
        taxNumber: "1234567890",
        licenseNumber: "IST-DIS-2018-0042",
        openingDate: .make(year: 2018, month: 3, day: 15),
        clinicType: .poliklinik,
        totalAreaSquareMeters: 320,
        rooms: [
            ClinicRoom(
                id: UUID().uuidString,
                name: "Tedavi Odası 1", roomNumber: "101",
                type: .treatment, areaSquareMeters: 18,
                floor: 1, hasWindow: true, hasSink: true,
                equipment: ["Sirona C8+ Diş Ünitesi", "Röntgen Sensörü"],
                assignedDoctorIds: [MockID.doctorYilmaz]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Tedavi Odası 2", roomNumber: "102",
                type: .treatment, areaSquareMeters: 18,
                floor: 1, hasWindow: true, hasSink: true,
                equipment: ["Kavo Diş Ünitesi", "Röntgen Sensörü"],
                assignedDoctorIds: [MockID.doctorDemir]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Ortodonti Odası", roomNumber: "103",
                type: .treatment, areaSquareMeters: 20,
                floor: 1, hasWindow: true, hasSink: true,
                equipment: ["Orthodontic Unit", "İntraoral Tarayıcı (iTero)"],
                assignedDoctorIds: [MockID.doctorArslan]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Panoramik Röntgen", roomNumber: "104",
                type: .xrayPanoramic, areaSquareMeters: 12,
                floor: 1, hasWindow: false, hasSink: false,
                equipment: ["Planmeca ProMax Panoramik"]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Sterilizasyon", roomNumber: "105",
                type: .sterilization, areaSquareMeters: 10,
                floor: 1, hasWindow: false, hasSink: true,
                equipment: ["Autoclave Class B", "Ultrasonik Yıkayıcı"]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Bekleme Salonu", roomNumber: "001",
                type: .waitingArea, areaSquareMeters: 35,
                floor: 0, hasWindow: true, hasSink: false
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Resepsiyon", roomNumber: "002",
                type: .reception, areaSquareMeters: 15,
                floor: 0, hasWindow: true, hasSink: false
            )
        ],
        equipmentSummary: ClinicEquipmentSummary(
            dentalUnitsCount: 3,
            panoramicXray: true,
            cbct: false,
            autoclaveClass: "B",
            hasCADCAM: false,
            hasLaser: true,
            hasIntraOralScanner: true
        )
    )

    static let kadikoy = Clinic(
        id: MockID.clinicKadikoy,
        name: "Bana Dental Clinic – Kadıköy",
        branchCode: "KDK-02",
        address: ClinicAddress(
            city: "İstanbul",
            district: "Kadıköy",
            neighborhood: "Moda Mah.",
            street: "Moda Caddesi",
            buildingNo: "88",
            postalCode: "34710",
            latitude: 40.9877,
            longitude: 29.0266
        ),
        phone: "+90 216 555 20 20",
        email: "kadikoy@banadental.com",
        website: "https://banadental.com",
        taxNumber: "9876543210",
        licenseNumber: "IST-DIS-2021-0117",
        openingDate: .make(year: 2021, month: 9, day: 1),
        clinicType: .muayenehane,
        totalAreaSquareMeters: 180,
        rooms: [
            ClinicRoom(
                id: UUID().uuidString,
                name: "Muayene Odası 1", roomNumber: "201",
                type: .muayene, areaSquareMeters: 16,
                floor: 2, hasWindow: true, hasSink: true,
                equipment: ["A-Dec 500 Diş Ünitesi"],
                assignedDoctorIds: [MockID.doctorSahin]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Muayene Odası 2", roomNumber: "202",
                type: .muayene, areaSquareMeters: 16,
                floor: 2, hasWindow: true, hasSink: true,
                equipment: ["A-Dec 300 Diş Ünitesi"],
                assignedDoctorIds: [MockID.doctorYilmaz]
            ),
            ClinicRoom(
                id: UUID().uuidString,
                name: "Bekleme", roomNumber: "200",
                type: .waitingArea, areaSquareMeters: 25,
                floor: 2, hasWindow: true, hasSink: false
            )
        ],
        equipmentSummary: ClinicEquipmentSummary(
            dentalUnitsCount: 2,
            panoramicXray: true,
            cbct: false,
            autoclaveClass: "S",
            hasCADCAM: false,
            hasLaser: false,
            hasIntraOralScanner: false
        )
    )

    static let all: [Clinic] = [atasehir, kadikoy]
}

// =========================================================================
// MARK: - MockDoctors
// =========================================================================
enum MockDoctors {

    static let yilmaz = Doctor(
        id: MockID.doctorYilmaz,
        name: "Dr. Kürşat Yılmaz",
        title: "Uzm. Dt.",
        specialty: "İmplantoloji",
        tagline: "Gülüşünüzü yeniden tasarlıyoruz",
        bio: "İstanbul Üniversitesi Diş Hekimliği Fakültesi'nden mezun olan Dr. Yılmaz, 14 yıllık klinik deneyimiyle implantoloji alanında uzmanlaşmıştır. Avrupa İmplant Akademisi üyesidir.",
        experience: "14 Yıl",
        patientCount: "4.200+",
        satisfactionRate: "%98",
        avatarInitials: "MY",
        avatarColorName: "blue",
        expertise: [
            DoctorExpertise(id: UUID().uuidString, title: "Dental İmplant",   icon: "cross.circle.fill",              colorName: "blue"),
            DoctorExpertise(id: UUID().uuidString, title: "Sinüs Lifting",    icon: "waveform.path.ecg",              colorName: "indigo"),
            DoctorExpertise(id: UUID().uuidString, title: "Kemik Grefti",     icon: "staroflife.fill",                colorName: "teal"),
            DoctorExpertise(id: UUID().uuidString, title: "Acil Diş",         icon: "bolt.heart.fill",                colorName: "red")
        ],
        education: [
            DoctorEducation(id: UUID().uuidString, degree: "Diş Hekimliği Lisans",   institution: "İstanbul Üniversitesi",    year: "2010"),
            DoctorEducation(id: UUID().uuidString, degree: "İmplantoloji Uzmanlık",  institution: "Marmara Üniversitesi",     year: "2013"),
            DoctorEducation(id: UUID().uuidString, degree: "EAO Sertifikası",         institution: "Avrupa İmplant Akademisi", year: "2016")
        ],
        languages: ["Türkçe", "İngilizce", "Almanca"],
        availableDays: ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"],
        clinicIds: [MockID.clinicAtasehir, MockID.clinicKadikoy]
    )

    static let demir = Doctor(
        id: MockID.doctorDemir,
        name: "Dr. Ayşe Demir",
        title: "Dt.",
        specialty: "Endodonti (Kanal Tedavisi)",
        tagline: "Dişlerinizi kurtarmak için buradayım",
        bio: "Hacettepe Üniversitesi mezunu Dr. Demir, 9 yıllık deneyimiyle karmaşık kanal tedavilerinde uzmanlaşmıştır. Mikroskop destekli endodonti alanında Türkiye'nin önde gelen isimlerinden biridir.",
        experience: "9 Yıl",
        patientCount: "2.800+",
        satisfactionRate: "%97",
        avatarInitials: "AD",
        avatarColorName: "purple",
        expertise: [
            DoctorExpertise(id: UUID().uuidString, title: "Kanal Tedavisi",        icon: "waveform.path.ecg.rectangle.fill", colorName: "purple"),
            DoctorExpertise(id: UUID().uuidString, title: "Mikroskop Endodonti",   icon: "magnifyingglass.circle.fill",      colorName: "indigo"),
            DoctorExpertise(id: UUID().uuidString, title: "Apikal Rezeksiyon",     icon: "scissors",                         colorName: "red"),
            DoctorExpertise(id: UUID().uuidString, title: "Vital Pulpa Tedavisi",  icon: "heart.text.square.fill",           colorName: "pink")
        ],
        education: [
            DoctorEducation(id: UUID().uuidString, degree: "Diş Hekimliği Lisans", institution: "Hacettepe Üniversitesi", year: "2015"),
            DoctorEducation(id: UUID().uuidString, degree: "Endodonti Doktora",     institution: "Hacettepe Üniversitesi", year: "2019")
        ],
        languages: ["Türkçe", "İngilizce"],
        availableDays: ["Pazartesi", "Çarşamba", "Cuma", "Cumartesi"],
        clinicIds: [MockID.clinicAtasehir]
    )

    static let arslan = Doctor(
        id: MockID.doctorArslan,
        name: "Dr. Kemal Arslan",
        title: "Uzm. Dt.",
        specialty: "Ortodonti",
        tagline: "Mükemmel bir gülüş, mükemmel bir yaşam",
        bio: "Ege Üniversitesi Ortodonti Anabilim Dalı'ndan uzman unvanı alan Dr. Arslan, görünmez diş teli (Invisalign) ve lingual ortodonti konularında sertifikalıdır.",
        experience: "11 Yıl",
        patientCount: "3.100+",
        satisfactionRate: "%96",
        avatarInitials: "KA",
        avatarColorName: "orange",
        expertise: [
            DoctorExpertise(id: UUID().uuidString, title: "Invisalign",         icon: "mouth.fill",                    colorName: "orange"),
            DoctorExpertise(id: UUID().uuidString, title: "Metal Braket",       icon: "square.grid.3x3.fill",          colorName: "blue"),
            DoctorExpertise(id: UUID().uuidString, title: "Lingual Ortodonti",  icon: "arrow.left.arrow.right",        colorName: "teal"),
            DoctorExpertise(id: UUID().uuidString, title: "Çocuk Ortodontisi",  icon: "figure.and.child.holdinghands", colorName: "yellow")
        ],
        education: [
            DoctorEducation(id: UUID().uuidString, degree: "Diş Hekimliği Lisans",   institution: "Ege Üniversitesi",    year: "2013"),
            DoctorEducation(id: UUID().uuidString, degree: "Ortodonti Uzmanlık",      institution: "Ege Üniversitesi",    year: "2017"),
            DoctorEducation(id: UUID().uuidString, degree: "Invisalign Sertifikası",  institution: "Align Technology",   year: "2019")
        ],
        languages: ["Türkçe", "İngilizce", "Fransızca"],
        availableDays: ["Salı", "Çarşamba", "Perşembe", "Cumartesi"],
        clinicIds: [MockID.clinicAtasehir]
    )

    static let sahin = Doctor(
        id: MockID.doctorSahin,
        name: "Dr. Selin Şahin",
        title: "Dt.",
        specialty: "Estetik Diş Hekimliği",
        tagline: "Estetik, doğal ve kalıcı gülüşler",
        bio: "Yeditepe Üniversitesi mezunu Dr. Şahin, dijital gülüş tasarımı ve porselen veneer uygulamalarında uzmanlaşmıştır. DSD (Digital Smile Design) sertifikasına sahiptir.",
        experience: "7 Yıl",
        patientCount: "1.900+",
        satisfactionRate: "%99",
        avatarInitials: "SS",
        avatarColorName: "pink",
        expertise: [
            DoctorExpertise(id: UUID().uuidString, title: "Porselen Veneer",          icon: "sparkles",                colorName: "pink"),
            DoctorExpertise(id: UUID().uuidString, title: "Dijital Gülüş Tasarımı",   icon: "camera.fill",             colorName: "purple"),
            DoctorExpertise(id: UUID().uuidString, title: "Kompozit Bonding",         icon: "paintbrush.pointed.fill", colorName: "yellow"),
            DoctorExpertise(id: UUID().uuidString, title: "Diş Beyazlatma",           icon: "sun.max.fill",            colorName: "orange")
        ],
        education: [
            DoctorEducation(id: UUID().uuidString, degree: "Diş Hekimliği Lisans",         institution: "Yeditepe Üniversitesi",        year: "2017"),
            DoctorEducation(id: UUID().uuidString, degree: "DSD Sertifikası",               institution: "Digital Smile Design Academy", year: "2020"),
            DoctorEducation(id: UUID().uuidString, degree: "Estetik Diş Hekimliği Sert.",  institution: "EAED",                        year: "2022")
        ],
        languages: ["Türkçe", "İngilizce"],
        availableDays: ["Pazartesi", "Salı", "Perşembe", "Cuma", "Cumartesi"],
        clinicIds: [MockID.clinicKadikoy]
    )

    static let all: [Doctor] = [yilmaz, demir, arslan, sahin]
}

enum MockPatients{
    
    static func sinan(id: String) -> Patient {
        Patient(
            id: id,
            firstName: "Sinan",
            lastName: "Dinç",
            birthDate: Date(timeIntervalSince1970: 315532800), // 1980
            gender: .male,
            phone: "05551234567",
            email: "ahmet.yilmaz@example.com",
            loyaltyPoints: 120,
            tcKimlikNo: "12345678901",
            bloodType: .aPos,
            toothSensitivityLevel: 2,
            alcoholStatus: .occasional,
            smokingStatus: .never
        )
    }
    
    static let ayşe: Patient = Patient(
            id: "2",
            firstName: "Ayşe",
            lastName: "Demir",
            birthDate: Date(timeIntervalSince1970: 504921600), // 1986
            gender: .female,
            phone: "05559876543",
            email: "ayse.demir@example.com",
            loyaltyPoints: 45,
            tcKimlikNo: "98765432100",
            bloodType: .aPos,
            toothSensitivityLevel: 1,
            alcoholStatus: .never,
            smokingStatus: .former
        )
        
    static let mehmet: Patient = Patient(
            id: "3",
            firstName: "Mehmet",
            lastName: "Kaya",
            birthDate: Date(timeIntervalSince1970: 662688000), // 1991
            gender: .male,
            phone: "05331234567",
            email: "mehmet.kaya@example.com",
            loyaltyPoints: 300,
            tcKimlikNo: "11122233344",
            bloodType: .aNeg,
            toothSensitivityLevel: 3,
            alcoholStatus: .occasional,
            smokingStatus: .current
        )
    
    static let all: [Patient] = [sinan(id: "PAQ6wtbFbkeGUHtq2Izfc3H2uDE3")]

}

enum MockServices {

    // =========================================================================
    // MARK: Aesthetic
    // =========================================================================

    static let lamina = Service(
        id: MockID.lamina,
        category: .aesthetic,
        title: "Lamina Kaplama",
        subtitle: "Minimal-Prep E.max Laminalar",
        description: "Dişin ön yüzeyine yapıştırılan ultra-ince seramik tabakalar. Neredeyse hiç aşındırma yapılmadan doğal ışık geçirgenliği ve zamansız estetik elde edilir.",
        tags: ["E.max", "Minimal İnvaziv", "Dijital Tasarım"],
        badgeText: nil,
        sfSymbol: "seal.fill",
        colorName: "yellow",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Kimler için uygun?",
                bullets: [
                    "Üst seviye, kalıcı estetik arayanlar",
                    "Renk ve form bozukluklarını uzun vadeli çözmek isteyenler"
                ]
            ),
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Nasıl uygulanır?",
                bullets: [
                    "Minimal-prep E.max laminalar tercih edilir",
                    "3D taramalarla kişiye özel tasarlanır",
                    "Laboratuvar destekli üretim sonrası profesyonel yapıştırma"
                ]
            ),
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Avantajları",
                bullets: [
                    "Doğal ışık geçirgenliği, zamansız estetik",
                    "Yüksek dayanıklılık",
                    "Uzun vadede stabil sonuçlar"
                ]
            )
        ],
        isActive: true
    )

    static let kompozitGulus = Service(
        id: MockID.kompozitGulüs,
        category: .aesthetic,
        title: "Kompozit Gülüş Tasarımı",
        subtitle: "Tek Seansta Dönüşüm",
        description: "Dişlere zarar vermeden form ve renk düzenlemeleri. 3D dijital planlama ile sonuç işlem öncesi öngörülür; kompozit materyal tabaka tabaka uygulanır.",
        tags: ["Tek Seans", "Konservatif", "Dijital Mock-up"],
        badgeText: nil,
        sfSymbol: "wand.and.stars",
        colorName: "pink",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Kimler için uygun?",
                bullets: [
                    "Sağlıklı diş yapısına sahip, küçük form veya renk bozuklukları olanlar",
                    "Hızlı ve bütçe dostu çözüm arayanlar"
                ]
            ),
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Nasıl uygulanır?",
                bullets: [
                    "Dişler kesilmez, yalnızca yüzey hazırlığı yapılır",
                    "Dijital mock-up ile gülüş önceden planlanır",
                    "Kompozit materyal tek seansta şekillendirilir"
                ]
            ),
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Avantajları",
                bullets: [
                    "Diş dokusu maksimum korunur",
                    "Hızlı sonuç: çoğunlukla tek seans",
                    "İstenirse lamina veya hibrit çözümlere dönüştürülebilir"
                ]
            )
        ],
        isActive: true
    )

    static let klinik3DUretim = Service(
        id: MockID.klinik3DUretim,
        category: .aesthetic,
        title: "Klinikte 3D Üretim",
        subtitle: "Same Day Restorasyon",
        description: "Türkiye'de bir ilk. Özel 3D yazıcılarla diş restorasyonları çok daha hızlı ve kişiye özel üretilebilecek. Minimal invaziv prensipler, maksimum estetik.",
        tags: ["Yakında", "3D Yazıcı", "İnnovasyon"],
        badgeText: "Çok Yakında",
        sfSymbol: "cube.transparent.fill",
        colorName: "purple",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Ne sunacak?",
                bullets: [
                    "Aynı gün teslim restorasyon imkânı",
                    "Kişiye özel dijital üretim",
                    "Minimal invaziv prensipler ile maksimum estetik"
                ]
            )
        ],
        isActive: true
    )

    // =========================================================================
    // MARK: Restorative
    // =========================================================================

    static let onlayOverlay = Service(
        id: MockID.onlayOverlay,
        category: .restorative,
        title: "Onlay & Overlay Restorasyonlar",
        subtitle: "CAD/CAM Teknolojisi",
        description: "Dişin tamamını kaplamadan yalnızca hasarlı bölgeyi restore eden çözümler. Dijital tarama ve CAD/CAM teknolojisiyle kişiye özel üretilir.",
        tags: ["CAD/CAM", "Doğal Doku Koruma", "Dayanıklı"],
        badgeText: nil,
        sfSymbol: "puzzlepiece.fill",
        colorName: "blue",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Özellikler",
                bullets: [
                    "Dişin yalnızca hasarlı bölgesi restore edilir",
                    "Dijital tarama ile hassas ölçü alınır",
                    "CAD/CAM teknolojisiyle kişiye özel üretim"
                ]
            )
        ],
        isActive: true
    )

    static let implantProtetik = Service(
        id: MockID.implantProtetik,
        category: .restorative,
        title: "İmplant & Protetik Çözümler",
        subtitle: "Straumann Implant Sistemi",
        description: "Eksik dişlerin yerine titanyum implantlar; üzerine porselen veya zirkonyum destekli protezler. Tüm süreç 3D planlama ile öngörülebilir şekilde hazırlanır.",
        tags: ["Straumann", "3D Planlama", "Zirkonyum"],
        badgeText: nil,
        sfSymbol: "bolt.shield.fill",
        colorName: "indigo",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Süreç",
                bullets: [
                    "3D planlama ile implant pozisyonu belirlenir",
                    "Güven ve uzun ömür için Straumann implant kullanılır",
                    "Porselen veya zirkonyum protezlerle tamamlanır",
                    "Fonksiyon, estetik ve biyouyumluluk bir arada sağlanır"
                ]
            )
        ],
        isActive: true
    )

    static let dolguKoruyucu = Service(
        id: MockID.dolguKoruyucu,
        category: .restorative,
        title: "Dolgu & Koruyucu Uygulamalar",
        subtitle: "Yüksek Kalite Kompozit",
        description: "Küçük çürükler minimal preparasyonla temizlenir, yüksek kalite kompozit dolgularla restore edilir. Fissür örtücüler ve florid desteğiyle uzun vadeli koruma.",
        tags: ["Kompozit Dolgu", "Fissür Örtücü", "Florid"],
        badgeText: nil,
        sfSymbol: "shield.lefthalf.filled",
        colorName: "green",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Uygulamalar",
                bullets: [
                    "Minimal preparasyon ile çürük temizliği",
                    "Yüksek kalite kompozit dolgu restorasyonu",
                    "Fissür örtücü uygulamaları",
                    "Florid desteği ve düzenli kontrol protokolleri"
                ]
            )
        ],
        isActive: true
    )

    static let taramaPlanlama = Service(
        id: MockID.taramaPlanlama,
        category: .restorative,
        title: "3D Tarama & Dijital Planlama",
        subtitle: "Öngörülebilir Tedavi",
        description: "Ağız içi yüksek çözünürlüklü taramalar ve dijital simülasyonlarla tedavi öngörülebilir hale gelir. Sonuç işlem başlamadan görülür.",
        tags: ["Dijital İz", "Simülasyon", "Kişiye Özel"],
        badgeText: nil,
        sfSymbol: "camera.metering.center.weighted",
        colorName: "teal",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Süreç",
                bullets: [
                    "Yüksek çözünürlüklü ağız içi tarama",
                    "Dijital simülasyon ile tedavi planlaması",
                    "Sonuç işlem öncesi hastaya gösterilir",
                    "Her adım kişiye özel planlanır"
                ]
            )
        ],
        isActive: true
    )

    static let emsTemizlik = Service(
        id: MockID.emsTemizlik,
        category: .restorative,
        title: "EMS / GBT Diş Temizliği",
        subtitle: "Airflow EMS Teknolojisi",
        description: "Klasik diş taşından öte, biyofilmi hedefleyen diş-diş eti dostu temizlik yöntemi. EMS AirFlow cihazlarıyla minimal invaziv, güvenli ve konforlu sonuçlar.",
        tags: ["EMS AirFlow", "Biyofilm", "Konforlu"],
        badgeText: nil,
        sfSymbol: "wind",
        colorName: "cyan",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Özellikler",
                bullets: [
                    "Biyofilm hedefli temizlik protokolü",
                    "EMS AirFlow cihazı ile uygulama",
                    "Diş ve diş eti dostu, minimal invaziv",
                    "Konforlu ve güvenli temizlik deneyimi"
                ]
            )
        ],
        isActive: true
    )

    static let seffafPlak = Service(
        id: MockID.seffafPlak,
        category: .restorative,
        title: "Şeffaf Plak (Aligner) Tedavisi",
        subtitle: "Görünmez Ortodonti",
        description: "Dişlerdeki çapraşıklık, boşluk veya hizalama sorunları tel kullanılmadan, görünmez şeffaf plaklarla düzeltilir. Dijital planlama ile öngörülebilir ilerleme.",
        tags: ["Aligner", "Görünmez", "Dijital Planlama"],
        badgeText: nil,
        sfSymbol: "mouth.fill",
        colorName: "orange",
        details: [
            ServiceDetail(
                id: UUID().uuidString,
                heading: "Tedavi Süreci",
                bullets: [
                    "Dijital planlama ile ideal konuma yol haritası",
                    "Plaklarla aşamalı diş hareketlendirmesi",
                    "Görünmez ve çıkarılabilir kullanım konforu",
                    "Estetikten ödün vermeden dengeli gülüş"
                ]
            )
        ],
        isActive: true
    )

    // =========================================================================
    // MARK: All
    // =========================================================================
    static let all: [Service] = [
        lamina, kompozitGulus, klinik3DUretim,
        onlayOverlay, implantProtetik, dolguKoruyucu,
        taramaPlanlama, emsTemizlik, seffafPlak
    ]
}

// =========================================================================
// MARK: - MockAppointments
// =========================================================================
enum MockAppointments {

    static let appt001 = Appointment(
        id: MockID.appt001,
        patientId: MockID.patientSinan,
        patientName: "Ahmet Kaya",
        doctorId: MockID.doctorYilmaz,
        doctorName: "Dr. Mehmet Yılmaz",
        doctorSpecialty: "İmplantoloji",
        clinicId: MockID.clinicAtasehir,
        date: .make(year: 2025, month: 9, day: 15, hour: 10, minute: 0),
        time: "10:00",
        durationMinutes: 60,
        type: .implant,
        status: .completed,
        notes: "Alt çene sağ bölge implant ameliyatı tamamlandı. Kontrol 1 hafta sonra.",
        roomNumber: "101",
        serviceId: MockID.implantProtetik
    )

    static let appt002 = Appointment(
        id: MockID.appt002,
        patientId: MockID.patientCelik,
        patientName: "Fatma Çelik",
        doctorId: MockID.doctorArslan,
        doctorName: "Dr. Kemal Arslan",
        doctorSpecialty: "Ortodonti",
        clinicId: MockID.clinicAtasehir,
        date: .make(year: 2025, month: 10, day: 3, hour: 14, minute: 30),
        time: "14:30",
        durationMinutes: 45,
        type: .orthodontics,
        status: .completed,
        notes: "Invisalign 3. aligner teslim edildi. Bir sonraki randevu 6 hafta sonra.",
        roomNumber: "103",
        serviceId: MockID.seffafPlak
    )

    static let appt003 = Appointment(
        id: MockID.appt003,
        patientId: MockID.patientAydin,
        patientName: "Mustafa Aydın",
        doctorId: MockID.doctorDemir,
        doctorName: "Dr. Ayşe Demir",
        doctorSpecialty: "Endodonti",
        clinicId: MockID.clinicAtasehir,
        date: .make(year: 2025, month: 10, day: 20, hour: 9, minute: 0),
        time: "09:00",
        durationMinutes: 90,
        type: .rootCanal,
        status: .cancelled,
        notes: "Hasta kan şekeri yüksek olduğu için randevuyu iptal etti.",
        roomNumber: "102",
        serviceId: MockID.kompozitGulüs
    )

    static let appt004 = Appointment(
        id: MockID.appt004,
        patientId: MockID.patientOzturk,
        patientName: "Zeynep Öztürk",
        doctorId: MockID.doctorSahin,
        doctorName: "Dr. Selin Şahin",
        doctorSpecialty: "Estetik Diş Hekimliği",
        clinicId: MockID.clinicKadikoy,
        date: .make(year: 2025, month: 11, day: 5, hour: 11, minute: 0),
        time: "11:00",
        durationMinutes: 120,
        type: .checkup,
        status: .upcoming,
        notes: "Dijital gülüş tasarımı için ilk konsültasyon.",
        roomNumber: "201",
        serviceId: MockID.kompozitGulüs
    )

    static let appt005 = Appointment(
        id: MockID.appt005,
        patientId: MockID.patientYildiz,
        patientName: "Ali Yıldız",
        doctorId: MockID.doctorYilmaz,
        doctorName: "Dr. Mehmet Yılmaz",
        doctorSpecialty: "İmplantoloji",
        clinicId: MockID.clinicKadikoy,
        date: .make(year: 2025, month: 11, day: 8, hour: 16, minute: 0),
        time: "16:00",
        durationMinutes: 30,
        type: .checkup,
        status: .upcoming,
        notes: "Kardiyolog onayı bekleniyor. Randevudan önce teyit edilecek.",
        roomNumber: "202",
        serviceId: MockID.dolguKoruyucu
    )

    static let appt006 = Appointment(
        id: MockID.appt006,
        patientId: MockID.patientSinan,
        patientName: "Ahmet Kaya",
        doctorId: MockID.doctorYilmaz,
        doctorName: "Dr. Mehmet Yılmaz",
        doctorSpecialty: "İmplantoloji",
        clinicId: MockID.clinicAtasehir,
        date: .make(year: 2025, month: 11, day: 22, hour: 10, minute: 30),
        time: "10:30",
        durationMinutes: 30,
        type: .checkup,
        status: .upcoming,
        notes: "İmplant osseointegrasyon kontrolü.",
        roomNumber: "101",
        serviceId: MockID.taramaPlanlama
    )

    static let all: [Appointment] = [appt001, appt002, appt003, appt004, appt005, appt006]
}
