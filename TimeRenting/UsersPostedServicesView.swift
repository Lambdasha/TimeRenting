//
//  UsersPostedServicesView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/9/24.
//
import SwiftUI
import CoreData

struct UsersPostedServicesView: View {
    var user: User
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest var postedServices: FetchedResults<Service>

    init(user: User) {
        self.user = user

        // FetchRequest for services posted by the user
        _postedServices = FetchRequest(
            entity: Service.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)],
            predicate: NSPredicate(format: "postedByUser == %@", user)
        )
    }

    var body: some View {
        ScrollView { // Add ScrollView for better layout
            VStack(alignment: .leading, spacing: 10) { // Add spacing between items
                if postedServices.isEmpty {
                    Text("No services posted by this user.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 20) // Add some top padding
                } else {
                    Text("\(user.username ?? "User")'s Posted Services")
                        .font(.title2)
                        .padding(.top)

                    ForEach(postedServices) { service in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.body)
                                .foregroundColor(.gray)
                            Divider()
                        }
                        .padding() // Add padding to each service card
                        .background(Color.gray.opacity(0.1)) // Optional: Add background color for better contrast
                        .cornerRadius(8) // Optional: Rounded corners
                    }
                }
            }
            .padding() // Add padding around the entire content
        }
    }
}
