//
//  SecondPage.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

// Second Page (Destination Page)
import SwiftUI
struct SecondPage: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MessagesView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }
            
            MeView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
        }
        .navigationTitle("Second Page") // Title for the second page
    }
}

