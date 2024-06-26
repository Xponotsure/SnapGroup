//
//  TemporarySelectTemplateView.swift
//  SnapGroup
//
//  Created by Ayatullah Ma'arif on 26/06/24.
//

import SwiftUI

struct TemporarySelectTemplateView: View {
    
    
    let numberOfPeople = [3,4,5,6,7,8]
    @State var selectedNumber = 3
    
    @State var templates: [Template] = TemplateData().groupOf3
    @State var selectedTemplate: Template?
    
    
    //    @State var images : [UIImage] = []
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    //    static func loadImages(selectedNumber: Int) -> [UIImage] {
    //        var images: [UIImage] = []
    //        var index = 0
    //        // Loop indefinitely until no more images are found
    //        while let image = UIImage(named: "GroupOf\(selectedNumber)/Preview/\(index)p") {
    //            images.append(image)
    //            index += 1
    //        }
    //        return images
    //    }
    
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Picker("Select a paint color", selection: $selectedNumber) {
                    ForEach(numberOfPeople, id: \.self) {item in
                        Text("\(item)")
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedNumber) { _, _ in

                    switch selectedNumber {
                    case 3:
                        templates = TemplateData().groupOf3
                    case 4:
                        templates = TemplateData().groupOf4
                    case 5:
                        templates = TemplateData().groupOf5
                    case 6:
                        templates = TemplateData().groupOf6
                    case 7:
                        templates = TemplateData().groupOf7
                    case 8:
                        templates = TemplateData().groupOf8
                    default:
                        break;
                        
                    }
                }
                
                LazyVGrid(columns: adaptiveColumn, spacing: 20) {
                    //                        ForEach(0..<templates.count, id: \.self) { index in
                    //                                TemplateGridItem(image: images[index], isSelected: images[index] == selectedImage )
                    //                                .onTapGesture {
                    //                                    selectedTemplate = images[index]
                    //                                }
                    //                        }
                    ForEach(templates, id: \.self){ template in
                        TemplateGridItem(image: template.previewImage, isSelected: template == selectedTemplate)
                        .onTapGesture {
                            selectedTemplate = template        
                        }

                    }
                    
                }
                
                
                
                NavigationLink(destination: CameraView(template: selectedTemplate)) {
                    Text("Select")
                }
                
            }
        }
    }
    
}

#Preview {
    TemporarySelectTemplateView()
}
