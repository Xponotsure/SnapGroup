//
//  Splash.swift
//  SnapGroup
//
//  Created by Faisal Alfa on 22/06/24.
//

import SwiftUI

struct Splash: View {
    var body: some View {
        VStack {
            Spacer()
            Circle().frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            Spacer()
            Text("Snap Group")
                .font(.headline)
        }
    }
}

#Preview {
    Splash()
}
