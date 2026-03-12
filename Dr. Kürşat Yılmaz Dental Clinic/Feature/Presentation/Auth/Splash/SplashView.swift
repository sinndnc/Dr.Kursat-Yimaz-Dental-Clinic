//
//  SplashView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image("ClinicLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipped()
                
                Text("Smile Brighter Every Day")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(18 / UIFont.preferredFont(forTextStyle: .headline).pointSize)
                    .lineLimit(1)
                    .padding(.top, 0)
            }
        }
    }
}
 
#Preview {
    SplashView()
}
