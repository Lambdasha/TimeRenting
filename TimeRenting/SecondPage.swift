//
//  SecondPage.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.

import SwiftUI

struct SecondPage: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        TabView {
            HomeView(authViewModel: authViewModel) // Pass the authViewModel to HomeView
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MessagesView(authViewModel: authViewModel) // Assuming MessagesView does not require authViewModel
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }
            
            ProfileView(authViewModel: authViewModel) // Pass the authViewModel to ProfileView
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .navigationBarBackButtonHidden(true)  // This will still not work if SecondPage is inside a NavigationStack
    }
}
