//
//
//  WelcomeIOS.swift
//  SnapGroup
//
//  Created by Faisal Alfa on 26/06/24.
//

import SwiftUI

struct WelcomeIOS: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Welcome to\nSnapGroup Photo")
                .font(
                    Font.custom("SF Pro", size: 34)
                        .weight(.bold)
                )
                .kerning(0.4)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 1, green: 0.72, blue: 0))
            
            // Subheadline/Regular
            
            Text("Easily capture stunning group photos with SnapGroup. Choose from a variety of templates,\nand start snapping memorable moments!")
              .font(Font.custom("SF Pro", size: 15))
              .multilineTextAlignment(.center)
              .foregroundColor(.white)
              .frame(width: 361, alignment: .top)
            
            // Button
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Continue").font(
                    Font.custom("SF Pro", size: 17)
                    .weight(.semibold)
                    )
                    .foregroundColor(.black)
            }).padding(.horizontal)
                .padding(.vertical)
                .frame(width: 361, alignment: .center)
                .background(Color(red: 1, green: 0.72, blue: 0))

                .cornerRadius(12)
        }
    
    
//        .padding(0)
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 50)
        .frame(height: 852, alignment: .bottom)
        .background(
          LinearGradient(
            stops: [
              Gradient.Stop(color: .black.opacity(0), location: 0.51),
              Gradient.Stop(color: .black, location: 0.75),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
          )
        )
    }

}

#Preview {
    WelcomeIOS()
}
