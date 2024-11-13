//
//  UserModel.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//


// User Model


import SwiftUI
import CoreData

class AuthViewModel: ObservableObject {
    @Published var currentUser: User? // Use Core Data's User entity directly
    
    // Access the Core Data context
    let context = PersistenceController.shared.container.viewContext
    
    func signUp(username: String, password: String, email: String) {
        // Create and save a new User entity
        let newUser = User(context: context)
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        do {
            try context.save()
            currentUser = newUser // Assign the Core Data User entity directly
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    func login(username: String, password: String) -> Bool {
        // Create a fetch request to find the user with the given username and password
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)

        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user // Assign the fetched User entity directly
                return true
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
        return false
    }
    
    func logout() {
        currentUser = nil // Clear the current user
    }
}


