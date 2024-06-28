//
//  HomeScreen.swift
//  SnapGroup
//
//  Created by Faisal Alfa on 22/06/24.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack (alignment: .leading){
            Rectangle().frame(height: 250)
            Text("Group Photo Time!")
                .font(.largeTitle)
                .fontWeight(.bold).padding(.horizontal)
            Text("Capture perfect group photos effortlessly with customizable templates. Choose a template and snap professional-quality group shots in seconds.").padding(.horizontal)
            Text("Let's have a group photo!").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(.bold).padding()
            HStack {
                Text("Tell us how many people you are, and we’ll give you the best template for your photo group!").padding(.horizontal)
                GroupBox {
                    DisclosureGroup("Number of People") {
                        Text("1")
                        Text("2")
                        Text("3")
                        Text("4")
                        Text("5")
                        Text("6")
                        Text("7")
                        Text("8")
                        Text("9")
                    }
                }
            }
            Spacer()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Next")
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 9))
            }).frame(maxWidth: .infinity, alignment: .center).padding()
        }
        .hideStatusBar()
    }
}

#Preview {
    HomeScreen()
}
