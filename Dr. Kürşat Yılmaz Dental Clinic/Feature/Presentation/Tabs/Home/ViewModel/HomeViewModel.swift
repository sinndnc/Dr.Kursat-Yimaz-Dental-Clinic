//
//  HomeViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/10/26.
//

import UIKit
import MapKit
import Combine
import Foundation

final class HomeViewModel: ObservableObject{
    
    
    @Published var showMap: Bool = false
    @Published var showAppointmentBadge: Bool = true
    @Published var currentTestimonialIndex = 0
    
    let phoneNumber = "905366360880"
    let destinationName = "Dr. Kürşat Yılmaz"
    let message = "Merhaba, bilgi almak istiyorum."
    let destinationCoordinate = CLLocationCoordinate2D(latitude: 41.085185, longitude: 29.027958)
    
    
    func sendWhatsAppMessage() {
        // Mesajı URL için kodla (boşluklar, Türkçe karakterler)
        let escapedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "whatsapp://send?phone=\(phoneNumber)&text=\(escapedMessage)"
        
        if let whatsappURL = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL)
            } else {
                // WhatsApp yüklü değilse alternatif işlem (örneğin Safari ile açma)
                let webURLString = "https://wa.me/\(phoneNumber)?text=\(escapedMessage)"
                if let webURL = URL(string: webURLString) {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }
    
    func openInAppleMaps() {
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destinationName
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func openInGoogleMaps() {
        let urlString = "comgooglemaps://?daddr=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&directionsmode=driving"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func openInYandex() {
        // Yandex Navi öncelikli (navigasyon odaklı)
        let naviURL = "yandexnavi://build_route_on_map?lat_to=\(destinationCoordinate.latitude)&lon_to=\(destinationCoordinate.longitude)"
        
        let mapsURL = "yandexmaps://maps.yandex.ru/?pt=\(destinationCoordinate.longitude),\(destinationCoordinate.latitude)&z=16&name=\(destinationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // Navi yüklüyse Navi'yi tercih et, yoksa Maps
        if UIApplication.shared.canOpenURL(URL(string: "yandexnavi://")!) {
            if let url = URL(string: naviURL) {
                UIApplication.shared.open(url)
            }
        } else if let url = URL(string: mapsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func openInWaze() {
        let urlString = "waze://?ll=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&navigate=yes"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func makePhoneCall() {
        if let url = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}
