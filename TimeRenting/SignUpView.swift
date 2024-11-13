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
    @Binding var isPresented: Bool  // Bind the presentation state

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
                isPresented = false // Close the sheet on successful sign-up
            }
            .padding()

            Button("Cancel") {
                isPresented = false // Close the sheet
            }
            .padding()
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}


