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
    @State private var cannotDeleteMessage: String?
    @State private var navigateToProfile: Bool = false
    @State private var navigateToEditService: Bool = false
    @State private var serviceToEdit: Service?

    @FetchRequest private var services: FetchedResults<Service>

    init(user: User, authViewModel: AuthViewModel) {
        self.user = user
        self.authViewModel = authViewModel

        // FetchRequest to dynamically fetch services posted by the user
        _services = FetchRequest(
            entity: Service.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)],
            predicate: NSPredicate(format: "postedByUser == %@", user)
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Posted Services")
                    .font(.largeTitle)
                    .padding()

                if services.isEmpty {
                    Text("No posted services available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List(services, id: \.self) { service in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)

                            HStack {
                                // Edit Button
                                Button(action: {
                                    handleEdit(service: service)
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

                                // Delete Button
                                Button(action: {
                                    handleDelete(service: service)
                                }) {
                                    Text("Delete")
                                        .font(.subheadline)
                                        .padding(8)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(5)
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
            .alert("Cannot Modify Service", isPresented: Binding<Bool>(
                get: { cannotDeleteMessage != nil },
                set: { if !$0 { cannotDeleteMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(cannotDeleteMessage ?? "")
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete Service"),
                    message: Text("Are you sure you want to delete this service?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let service = serviceToDelete {
                            deleteService(service)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationDestination(isPresented: $navigateToEditService) {
                if let serviceToEdit = serviceToEdit {
                    EditServiceView(service: serviceToEdit)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func handleEdit(service: Service) {
        if let _ = getBookedUser(for: service) {
            cannotDeleteMessage = "This service cannot be edited because it has already been booked."
        } else {
            serviceToEdit = service
            navigateToEditService = true
        }
    }

    private func handleDelete(service: Service) {
        if let _ = getBookedUser(for: service) {
            cannotDeleteMessage = "This service cannot be deleted because it has already been booked."
        } else {
            serviceToDelete = service
            showingDeleteConfirmation = true
        }
    }

    private func getBookedUser(for service: Service) -> User? {
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)

        do {
            let bookings = try viewContext.fetch(fetchRequest)
            return bookings.first?.user
        } catch {
            print("Error checking service bookings: \(error.localizedDescription)")
            return nil
        }
    }

    private func deleteService(_ service: Service) {
        viewContext.delete(service)
        do {
            try viewContext.save()
            print("Service deleted successfully.")
        } catch {
            print("Error deleting service: \(error.localizedDescription)")
        }
    }
}
