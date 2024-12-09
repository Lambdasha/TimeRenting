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
    @ObservedObject var authViewModel: AuthViewModel // Pass authViewModel as a parameter
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteConfirmation = false
    @State private var serviceToDelete: Service?
    @State private var cannotDeleteMessage: String?
    @State private var userToMessage: User?
    @State private var navigateToProfile: Bool = false // State for navigation to ProfileViewForUser

    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Posted Services")
                    .font(.largeTitle)
                    .padding()

                if user.servicePosted?.allObjects.isEmpty ?? true {
                    Text("No posted services available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List((user.servicePosted?.allObjects as? [Service]) ?? [], id: \.self) { service in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)

                            // Delete Button
                            Button(action: {
                                if let bookedUser = getBookedUser(for: service) {
                                    userToMessage = bookedUser
                                    cannotDeleteMessage = "This service cannot be deleted because it has already been booked."
                                } else {
                                    serviceToDelete = service
                                    showingDeleteConfirmation = true
                                }
                            }) {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
            .alert("Cannot Delete Service", isPresented: Binding<Bool>(
                get: { cannotDeleteMessage != nil },
                set: { if !$0 { cannotDeleteMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
                if userToMessage != nil {
                    Button("View Profile") {
                        navigateToProfile = true // Trigger navigation
                    }
                }
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
            .navigationDestination(isPresented: $navigateToProfile) {
                if let userToMessage = userToMessage {
                    ProfileViewForUser(user: userToMessage, authViewModel: authViewModel)
                }
            }
        }
    }

    // Function to check if a service is already booked
    private func getBookedUser(for service: Service) -> User? {
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)

        do {
            let bookings = try viewContext.fetch(fetchRequest)
            return bookings.first?.user // Return the first user who booked the service
        } catch {
            print("Error checking service bookings: \(error.localizedDescription)")
            return nil
        }
    }

    // Function to delete a service
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
