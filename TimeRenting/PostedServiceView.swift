//
//  PostedServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/6/24.
//
import CoreData
import SwiftUI

struct PostedServicesView: View {
    let user: User
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteConfirmation = false
    @State private var serviceToDelete: Service?
    @State private var userToMessage: User? // Tracks the user who booked the service
    @State private var navigateToProfile: Bool = false
    @State private var navigateToEditService: Bool = false
    @State private var selectedService: Service? // Tracks the selected service for editing or viewing reviews
    @State private var navigateToViewReview: Bool = false

    @State private var selectedFilter: ServiceFilter = .all

    // Enum for filter options
    enum ServiceFilter: String, CaseIterable {
        case all = "All Services"
        case unbooked = "Unbooked"
        case booked = "Booked"
    }

    @FetchRequest private var services: FetchedResults<Service>

    init(user: User, authViewModel: AuthViewModel) {
        self.user = user
        self.authViewModel = authViewModel

        _services = FetchRequest(
            entity: Service.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)],
            predicate: NSPredicate(format: "postedByUser == %@", user)
        )
    }

    var body: some View {
            VStack {
                // Filter Picker
                Picker("Filter Services", selection: $selectedFilter) {
                    ForEach(ServiceFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Text("Your Posted Services")
                    .font(.largeTitle)
                    .padding()

                let filteredServices = applyFilter(selectedFilter)

                if filteredServices.isEmpty {
                    Text("No services available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List(filteredServices, id: \.self) { service in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)

                            HStack {
                                if getBookedUser(for: service) == nil {
                                    // Unbooked Services
                                    Button(action: {
                                        selectedService = service
                                        navigateToEditService = true
                                    }) {
                                        Text("Edit")
                                            .font(.subheadline)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(5)
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    Spacer()

                                    Button(action: {
                                        serviceToDelete = service
                                        showingDeleteConfirmation = true
                                    }) {
                                        Text("Delete")
                                            .font(.subheadline)
                                            .padding(8)
                                            .background(Color.red.opacity(0.2))
                                            .cornerRadius(5)
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                } else {
                                    // Booked Services
                                    if hasReview(for: service) {
                                        Button(action: {
                                            selectedService = service
                                            navigateToViewReview = true
                                        }) {
                                            Text("View Review")
                                                .font(.subheadline)
                                                .padding(8)
                                                .background(Color.purple.opacity(0.2))
                                                .cornerRadius(5)
                                                .foregroundColor(.purple)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    } else {
                                        Button(action: {
                                            userToMessage = getBookedUser(for: service)
                                            navigateToProfile = true
                                        }) {
                                            Text("View Profile")
                                                .font(.subheadline)
                                                .padding(8)
                                                .background(Color.orange.opacity(0.2))
                                                .cornerRadius(5)
                                                .foregroundColor(.orange)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
            .alert("Delete Service", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let service = serviceToDelete {
                        deleteService(service)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this service?")
            }
            .navigationDestination(isPresented: $navigateToEditService) {
                if let serviceToEdit = selectedService {
                    EditServiceView(service: serviceToEdit)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                if let userToMessage = userToMessage {
                    ProfileViewForUser(user: userToMessage, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationDestination(isPresented: $navigateToViewReview) {
                if let selectedService = selectedService {
                    ViewReviewView(service: selectedService)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
    }

    private func applyFilter(_ filter: ServiceFilter) -> [Service] {
        switch filter {
        case .all:
            return services.filter { $0.postedByUser == user }
        case .unbooked:
            return services.filter { $0.postedByUser == user && getBookedUser(for: $0) == nil }
        case .booked:
            return services.filter { $0.postedByUser == user && getBookedUser(for: $0) != nil }
        }
    }

    private func deleteService(_ service: Service) {
        viewContext.delete(service)
        try? viewContext.save()
    }

    private func getBookedUser(for service: Service) -> User? {
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)

        do {
            return try viewContext.fetch(fetchRequest).first?.user
        } catch {
            print("Error fetching booked user: \(error.localizedDescription)")
            return nil
        }
    }

    private func hasReview(for service: Service) -> Bool {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)

        do {
            return !(try viewContext.fetch(fetchRequest).isEmpty)
        } catch {
            print("Error fetching reviews: \(error.localizedDescription)")
            return false
        }
    }
}
