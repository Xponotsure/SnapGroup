//
//  StatusBarHiddenModifier.swift
//  SnapGroup
//
//  Created by Channy Lim on 28/06/24.
//

import SwiftUI

struct StatusBarHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .statusBar(hidden: true)
            .edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func hideStatusBar() -> some View {
        self.modifier(StatusBarHiddenModifier())
    }
}
