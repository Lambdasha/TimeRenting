//
//  LoginView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool // Bind to the sheet presentation
    @State private var isLoggedIn: Bool = false // Track login success
    @State private var errorMessage: String? // Store error message

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Login") {
                if authViewModel.login(username: username, password: password) {
                    isLoggedIn = true // Set to true on successful login
                    errorMessage = nil // Clear any previous error message
                    isPresented = false // Dismiss the login view
                } else {
                    errorMessage = "Username and password do not match. Please try again."
                }
            }
            .padding()

            // Display error message if login fails
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .padding()
        .navigationTitle("Login")
    }
}


