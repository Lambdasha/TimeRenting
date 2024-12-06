//
//  PostServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 11/11/24.
//

import SwiftUI
import CoreData

struct PostServiceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @ObservedObject var authViewModel: AuthViewModel

    @State private var serviceTitle = ""
    @State private var serviceDescription = ""
    @State private var serviceLocation = ""

    var body: some View {
        VStack {
            TextField("Service Title", text: $serviceTitle)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Description", text: $serviceDescription)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Location", text: $serviceLocation)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Post Service") {
                postService()
                isPresented = false // Dismiss the sheet after posting
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func postService() {
        guard let currentUser = authViewModel.currentUser else {
            print("Error: No user is currently logged in.")
            return
        }
        
        let newService = Service(context: viewContext)
        newService.serviceTitle = serviceTitle
        newService.serviceDescription = serviceDescription
        newService.serviceLocation = serviceLocation
        newService.timestamp = Date()
        newService.postedByUser = fetchUserEntity(username: currentUser.username ?? "")

        do {
            try viewContext.save()
            print("Service saved successfully.")
        } catch {
            // Handle error
            print("Error saving service: \(error.localizedDescription)")
        }
    }

    // Helper function to fetch the corresponding User entity from Core Data
    private func fetchUserEntity(username: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)

        do {
            let users = try viewContext.fetch(request)
            return users.first
        } catch {
            print("Failed to fetch user: \(error.localizedDescription)")
            return nil
        }
    }
}




