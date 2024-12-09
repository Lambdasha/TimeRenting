//
//  SignUpView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//
import SwiftUI
import CoreData // Import Core Data for fetch requests

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var errorMessage: String? // State for displaying errors
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool // Bind the presentation state
    @Environment(\.managedObjectContext) private var viewContext // Core Data context
    @State private var navigateToProfile = false // State for navigation

    var body: some View {
        NavigationView {
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

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }

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
            .navigationDestination(isPresented: $navigateToProfile) {
                ProfileView(authViewModel: authViewModel)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    // Function to handle sign-up
    private func signUpUser() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        // Check for duplicate username or email
        if isDuplicateUser(username: username, email: email) {
            errorMessage = "Username or email is already registered."
            return
        }

        // Create a new user in Core Data
        let newUser = User(context: viewContext)
        newUser.username = username
        newUser.email = email
        newUser.password = password
        newUser.timeCredits = 10 // Default starting credits

        do {
            try viewContext.save()
            print("User created successfully with initial time credits.")
            authViewModel.currentUser = newUser // Set the current user in AuthViewModel
            navigateToProfile = true // Trigger navigation to ProfileView
            isPresented = false // Close the sheet
        } catch {
            errorMessage = "Error creating user: \(error.localizedDescription)"
        }
    }

    // Function to check for duplicate username or email
    private func isDuplicateUser(username: String, email: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "username == %@", username),
            NSPredicate(format: "email == %@", email)
        ])

        do {
            let users = try viewContext.fetch(fetchRequest)
            return !users.isEmpty // If there are results, username or email is already registered
        } catch {
            print("Error checking for duplicate user: \(error.localizedDescription)")
            return false
        }
    }
}
