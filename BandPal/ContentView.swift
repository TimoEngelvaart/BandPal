//
//  ContentView.swift
//  BandPal
//
//  Created by Timo Engelvaart on 25/10/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            if selectedTab == 0 {
                SetlistView(selectedTab: $selectedTab)
            } else {
                RehearsalsView(selectedTab: $selectedTab)
            }

            // Custom bottom navigation
            BottomBorderView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
