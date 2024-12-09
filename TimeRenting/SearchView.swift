//
//  SearchView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/8/24.
//
import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var authViewModel: AuthViewModel

    @State private var searchText: String = ""
    @State private var selectedUser: User?
    @State private var selectedService: Service?

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search by username or service content", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if !searchText.isEmpty {
                    List {
                        Section(header: Text("Users")) {
                            ForEach(fetchUsers(searchText: searchText), id: \.self) { user in
                                Button(action: {
                                    selectedUser = user
                                }) {
                                    Text(user.username ?? "Unknown User")
                                        .font(.headline)
                                }
                            }
                        }

                        Section(header: Text("Services")) {
                            ForEach(fetchServices(searchText: searchText), id: \.self) { service in
                                Button(action: {
                                    selectedService = service
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(service.serviceTitle ?? "Untitled Service")
                                            .font(.headline)
                                        Text(service.serviceDescription ?? "No Description")
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationDestination(for: User.self) { user in
                ProfileViewForUser(user: user) // Navigate to ProfileViewForUser
            }
            .navigationDestination(for: Service.self) { service in
                BookingView(authViewModel: authViewModel, service: service) // Navigate to BookingView
            }
        }
    }


    private func fetchUsers(searchText: String) -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username CONTAINS[cd] %@", searchText)
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
            return []
        }
    }

    private func fetchServices(searchText: String) -> [Service] {
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        request.predicate = NSPredicate(format: "serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@", searchText, searchText)
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching services: \(error.localizedDescription)")
            return []
        }
    }
}
