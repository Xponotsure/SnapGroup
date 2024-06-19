//
//  ContentView.swift
//  SnapGroup
//
//  Created by Ayatullah Ma'arif on 19/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var imageData: Data? = nil
    @State private var showCamera: Bool = false
    
    var body: some View {
        VStack {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
            Button("Take Photo") {
                showCamera = true
            }
            .padding()
        }
        .padding()
        .fullScreenCamera(isPresented: $showCamera, imageData: $imageData)
    }
}
    
#Preview {
    ContentView()
}
