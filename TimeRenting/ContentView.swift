//
//  ContentView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 9/17/24.
//

import SwiftUI
import CoreData



// First Page (Main Page)
struct ContentView: View {
    var body: some View {
        NavigationView { // Main NavigationView
            VStack {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Rent your time")
                    .font(.largeTitle)
                
                // NavigationLink to go to the second page
                NavigationLink(destination: SecondPage()) {
                    Text("Get started")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// Second Page (Destination Page)
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

// Home View
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home Page")
                .font(.largeTitle)
                .padding()
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        .navigationTitle("Home")
    }
}

// Messages View
struct MessagesView: View {
    var body: some View {
        VStack {
            Text("Messages Page")
                .font(.largeTitle)
                .padding()
            Image(systemName: "message.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        .navigationTitle("Messages")
    }
}

// Me View
struct MeView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "clock")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Rent your time")

            NavigationLink(destination: SignUpView(authViewModel: authViewModel)) {
                Text("Sign Up")
            }
            .padding()

            NavigationLink(destination: LoginView(authViewModel: authViewModel)) {
                Text("Login")
            }
            .padding()
        }
        .padding()
        .navigationTitle("Me")
    }
}

// User Model
struct UserModel {
    var username: String
    var password: String
    var email: String
}

class AuthViewModel: ObservableObject {
    @Published var currentUser: UserModel? // Change this to UserModel
    
    // Access the Core Data context
    let context = PersistenceController.shared.container.viewContext
    
    func signUp(username: String, password: String, email: String) {
        let newUser = User(context: context) // Assuming UserEntity is your Core Data model
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        do {
            try context.save()
            currentUser = UserModel(username: username, password: password, email: email) // Update this line
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    func login(username: String, password: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)

        do {
            let users = try context.fetch(request)
            if let user = users.first {
                if let username = user.username, let password = user.password, let email = user.email {
                    currentUser = UserModel(username: username, password: password, email: email)
                    return true
                } else {
                    print("User information is incomplete.")
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
        return false
    }
    
    func logout() {
        currentUser = nil
    }
}

// Sign Up View
struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @ObservedObject var authViewModel: AuthViewModel

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
            }
            .padding()

            NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                Text("Go to Profile")
            }
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}

// Login View
struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @ObservedObject var authViewModel: AuthViewModel

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
                    // Successfully logged in, navigate to ProfileView
                }
            }
            .padding()

            NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                Text("Go to Profile")
            }
        }
        .padding()
        .navigationTitle("Login")
    }
}

// Profile View
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

#Preview {
    ContentView()
}
