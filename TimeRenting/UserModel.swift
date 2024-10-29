//
//  UserModel.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//


// User Model

import SwiftUI
import CoreData
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

