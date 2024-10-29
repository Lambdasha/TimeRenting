//
//  ProfileView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//
// Profile View

import SwiftUI
struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            if let user = authViewModel.currentUser { // Use optional binding
                Text("Welcome, \(user.username)!") // Now it's safely unwrapped
                    .font(.largeTitle)

                Text("Email: \(user.email)")
                    .padding()

                Button("Logout") {
                    authViewModel.logout()
                }
                .padding()
            } else {
                Text("No user logged in")
                    .font(.title)
            }
        }
        .padding()
        .navigationTitle("Profile")
    }
}
