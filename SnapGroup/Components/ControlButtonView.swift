//
//  ControlButtonView.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI
struct ControlButtonView: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .tint(.white)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}


//#Preview {
 //   ControlButtonView(label: "Cancel", action: {})
//}
