//
//  SearchView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/8/24.
//
import SwiftUI
import CoreData

struct SearchView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var searchText: String = ""
    @State private var selectedUser: User? = nil
    @State private var selectedService: Service? = nil
    @State private var searchFilter: SearchFilter = .username // Default filter
    
    enum SearchFilter: String, CaseIterable {
        case username = "Username"
        case serviceContent = "Service Content"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filter Picker
                Picker("Search By", selection: $searchFilter) {
                    ForEach(SearchFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Search Field
                TextField("Search by \(searchFilter.rawValue)", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Search Results
                if !searchText.isEmpty {
                    List {
                        if searchFilter == .username {
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
                        } else {
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
            }
            .navigationTitle("Search")
            .navigationDestination(isPresented: Binding(
                get: { selectedUser != nil },
                set: { if !$0 { selectedUser = nil } }
            )) {
                if let user = selectedUser {
                    ProfileViewForUser(user: user, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedService != nil },
                set: { if !$0 { selectedService = nil } }
            )) {
                if let service = selectedService {
                    BookingView(authViewModel: authViewModel, service: service)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
        
        // Fetch Users Based on Search Text
        private func fetchUsers(searchText: String) -> [User] {
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "username CONTAINS[cd] %@", searchText)
            do {
                return try viewContext.fetch(request)
            } catch {
                print("Error fetching users: \(error)")
                return []
            }
        }
        
        // Fetch Services Based on Search Text
        private func fetchServices(searchText: String) -> [Service] {
            let request: NSFetchRequest<Service> = Service.fetchRequest()
            request.predicate = NSPredicate(format: "serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@", searchText, searchText)
            do {
                return try viewContext.fetch(request)
            } catch {
                print("Error fetching services: \(error)")
                return []
            }
        }
}

