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
        VStack {
            if postedServices.isEmpty {
                Text("No services posted by this user.")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List(postedServices) { service in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(service.serviceTitle ?? "Untitled Service")
                            .font(.headline)
                        Text(service.serviceDescription ?? "No Description")
                            .font(.subheadline)
                        Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                            .font(.footnote)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .navigationTitle("\(user.username ?? "User")'s Posted Services")
    }
}
