//
//  EditablePatientAvatar.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//

import SwiftUI

struct EditablePatientAvatar: View {
    let patient: Patient
    var size: CGFloat = 80
    
    @EnvironmentObject var vm: ProfileViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
               if let url = vm.profilePhotoURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Text(patient.avatarLetter)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.accentColor)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())

            // Kalem ikonu
            Image(systemName: "camera.circle.fill")
                .font(.system(size: size * 0.28))
                .foregroundStyle(.white, Color.accentColor)
                .background(Color.white.clipShape(Circle()))
        }
    }
}
