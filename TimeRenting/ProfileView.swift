//
//  ProfileView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
import SwiftUI

struct ProfileView: View {
    @StateObject var authViewModel: AuthViewModel // StateObject for managing the authentication state
    @State private var isPostServicePresented = false // To control the presentation of the post service view
    @State private var isLoginPresented = false // To control the presentation of the login view
    @State private var isSignUpPresented = false // To control the presentation of the sign-up view

    var body: some View {
        VStack {
            if let user = authViewModel.currentUser { // Check if the user is logged in
                // Display profile information if the user is logged in
                Text("Welcome, \(user.username ?? "Unknown")!")
                    .font(.largeTitle)

                Text("Email: \(user.email ?? "No email provided")")
                    .padding()

                // Logout Button
                Button("Logout") {
                    authViewModel.logout()
                }
                .padding()

                // Post Service Button
                Button("Post a Service") {
                    isPostServicePresented = true
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            } else {
                // Display message if the user is not logged in
                Text("No user logged in")
                    .font(.title)
                    .padding()

                // Sign-Up Button
                Button("Sign Up") {
                    isSignUpPresented = true
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                // Login Button
                Button("Login") {
                    isLoginPresented = true
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Profile")
        .sheet(isPresented: $isPostServicePresented) {
            PostServiceView(isPresented: $isPostServicePresented, authViewModel: authViewModel)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
        .sheet(isPresented: $isLoginPresented) {
            LoginView(authViewModel: authViewModel, isPresented: $isLoginPresented)
        }
        .sheet(isPresented: $isSignUpPresented) {
            SignUpView(authViewModel: authViewModel, isPresented: $isSignUpPresented)
        }
    }
}


