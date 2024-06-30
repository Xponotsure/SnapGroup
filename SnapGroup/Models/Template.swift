//
//  Template.swift
//  SnapGroup
//
//  Created by Ayatullah Ma'arif on 25/06/24.
//

import Foundation
import SwiftUI

struct Template : Hashable{
    var previewImage: String
    var silhouetteImage: String
    var orientation: Orientation
    var pathLogic: [CGRect]
}

enum Orientation: String{
    case potrait, landscape
}
