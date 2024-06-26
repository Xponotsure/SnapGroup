//
//  SillhouteView.swift
//  SnapGroup
//
//  Created by Ayatullah Ma'arif on 26/06/24.
//

import SwiftUI

struct TemplateData{
    var groupOf3: [Template] = [
        Template(
            previewImage: "GroupOf3/Preview/0p",
            sillhouteImage: "GroupOf3/Sillhoute/0s",
            pathLogic: [
                CGRect(x: 70, y: 190, width: 100, height: 100),
                CGRect(x: 215, y: 185, width: 100, height: 100),
                CGRect(x: 130, y: 320, width: 120, height: 130)

            ]
        )
    ]
    
    var groupOf4: [Template] = [
        
    ]
    
    var groupOf5: [Template] = [
        
    ]
    
    var groupOf6: [Template] = [
        
    ]
    
    var groupOf7: [Template] = [
       
    ]
    
    var groupOf8: [Template] = [
        
    ]
}

struct SillhouteView: View {
    var template: Template
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                ZStack {
                    
                    // MARK: Untuk check path dengan template
                    // kalau udah Image di comment lagi
                    Image(template.previewImage)
                        .resizable()
                        .scaledToFit()
                    
                    
                    ForEach(template.pathLogic, id: \.self) { rect in
//                        let isIntersecting = cameraService.detectedFaces.contains { face in
//                            let faceRect = cameraService.convertBoundingBox(face.boundingBox, screenSize: geometry.size)
//                            return rect.intersects(faceRect)
//                        }
                        Rectangle()
                            .path(in: rect)
//                            .stroke(isIntersecting ? Color.green : Color.blue, lineWidth: 5)
                            .stroke(Color.blue, lineWidth: 5)
                    }
                }
            }
        }
    }
}

#Preview {
    SillhouteView(template: TemplateData().groupOf3[0])
}
