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
            silhouetteImage: "GroupOf3/Sillhoute/0s",
            orientation: .potrait,
            pathLogic: [
                CGRect(x: 60, y: 85, width: 100, height: 100),
                CGRect(x: 200, y: 75, width: 100, height: 100),
                CGRect(x: 125, y: 195, width: 120, height: 130)
                
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
    
    @ObservedObject var cameraVM: CameraViewModel
    
    
    var body: some View {
        ZStack{
            
            Image(template.silhouetteImage)
                .resizable()
                .scaledToFit()
                .overlay{
                    GeometryReader{ geo in
                        ForEach(template.pathLogic, id: \.self) { rect in
                            Rectangle()
                                .path(in: rect)
                                .stroke(Color.clear , lineWidth: 2)
                            
                                // untuk test, command lagi kalo udah
//                                .stroke(Color.blue , lineWidth: 2)

                        }
                        
                    }
                }
        }
    }
}



#Preview {
    SillhouteView(template: TemplateData().groupOf3[0], cameraVM: CameraViewModel())
}
