//
//  ContentView.swift
//  BandPal
//
//  Created by Timo Engelvaart on 25/10/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(Font.custom("Urbanist-Regular", size: 24))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
