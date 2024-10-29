//
//  SignUpView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

import SwiftUI

// Sign Up View
struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isSignedUp: Bool = false // Track sign-up completion

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Sign Up") {
                authViewModel.signUp(username: username, password: password, email: email)
                isSignedUp = authViewModel.currentUser != nil // Update completion status based on user presence
            }
            .padding()

            // Conditional NavigationLink based on isSignedUp status
            NavigationLink(destination: ProfileView(authViewModel: authViewModel), isActive: $isSignedUp) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}
