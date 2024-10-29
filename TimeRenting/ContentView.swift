//
//  ContentView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 9/17/24.
//

import SwiftUI
import CoreData

// First Page (Main Page)
struct ContentView: View {
    var body: some View {
        NavigationView { // Main NavigationView
            VStack {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Rent your time")
                    .font(.largeTitle)
                
                // NavigationLink to go to the second page
                NavigationLink(destination: SecondPage()) {
                    Text("Get started")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}



#Preview {
    ContentView()
}
