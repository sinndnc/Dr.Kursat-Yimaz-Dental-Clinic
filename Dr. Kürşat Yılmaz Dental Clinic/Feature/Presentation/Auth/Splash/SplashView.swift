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
            // Background — systemGray6Color
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Logo — 120x120, centered (same as storyboard centerX/centerY)
                Image("ClinicLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipped()
                
                // Label — top offset is 485 - (366 + 120) = -1 → sits right below logo (≈ default spacing)
                Text("Smile Brighter Every Day")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(18 / UIFont.preferredFont(forTextStyle: .headline).pointSize)
                    .lineLimit(1)
                    .padding(.top, 0)   // label frame.y (485) - imageView.maxY (486) ≈ 0
            }
        }
    }
}
 
#Preview {
    SplashView()
}
