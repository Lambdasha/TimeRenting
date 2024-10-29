//
//  HomeView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

import SwiftUI

// Home View
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home Page")
                .font(.largeTitle)
                .padding()
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        .navigationTitle("Home")
    }
}
