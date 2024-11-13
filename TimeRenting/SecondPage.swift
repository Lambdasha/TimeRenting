//
//  SecondPage.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

// SecondPage.swift
// TimeRenting

import SwiftUI
struct SecondPage: View {
    @StateObject var authViewModel = AuthViewModel()

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
            
            ProfileView(authViewModel: authViewModel) // Use ProfileView instead of MeView
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .navigationTitle("Second Page")
    }
}


