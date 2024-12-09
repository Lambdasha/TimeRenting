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
    @Environment(\.managedObjectContext) private var viewContext  // Core Data context

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
                signUpUser()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Cancel") {
                isPresented = false // Close the sheet
            }
            .padding()
        }
        .padding()
        .navigationTitle("Sign Up")
    }

    // Function to handle sign-up and initialize user credits
    private func signUpUser() {
        authViewModel.signUp(username: username, password: password, email: email)

        // Create a new user in Core Data with default credits
        let newUser = User(context: viewContext)
        newUser.username = username
        newUser.email = email
        newUser.password = password
        newUser.timeCredits = 100 // Default starting credits

        do {
            try viewContext.save()
            print("User created successfully with initial time credits.")
            isPresented = false // Close the sheet
        } catch {
            print("Error creating user: \(error.localizedDescription)")
        }
    }
}
