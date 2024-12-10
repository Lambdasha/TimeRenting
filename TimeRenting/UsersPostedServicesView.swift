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
    @ObservedObject var authViewModel: AuthViewModel // Added authViewModel as a required parameter
    @State private var selectedService: Service? // Tracks the selected service for navigation

    @FetchRequest var postedServices: FetchedResults<Service>

    init(user: User, authViewModel: AuthViewModel) {
        self.user = user
        self.authViewModel = authViewModel

        // FetchRequest for services posted by the user
        _postedServices = FetchRequest(
            entity: Service.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)],
            predicate: NSPredicate(format: "postedByUser == %@", user)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if postedServices.isEmpty {
                        Text("No services posted by this user.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {

                        ForEach(postedServices, id: \.objectID) { service in
                            NavigationLink(destination: BookingView(authViewModel: authViewModel, service: service)) { // Pass authViewModel
                                ServiceCardView(service: service) // Extracted into a separate reusable view
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(user.username ?? "User")'s Posted Services")
        }
    }
}

struct ServiceCardView: View {
    let service: Service

    var body: some View {
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
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
