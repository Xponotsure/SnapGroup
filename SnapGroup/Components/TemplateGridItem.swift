//
//  TemplateGridItem.swift
//  SnapGroup
//
//  Created by Ayatullah Ma'arif on 26/06/24.
//

import SwiftUI

struct TemplateGridItem: View {
    var image: String
    var isSelected: Bool
    
    var body: some View {
        ZStack{
            
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 150) // Adjust the frame height as needed
                .padding()
            
            if isSelected{
                Rectangle()
                    .fill(.blue)
                    .opacity(0.5)
            }


        }
    }
}
