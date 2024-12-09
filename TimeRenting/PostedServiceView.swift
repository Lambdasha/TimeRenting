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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteConfirmation = false
    @State private var serviceToDelete: Service?

    var body: some View {
        VStack {
            Text("Your Posted Services")
                .font(.largeTitle)
                .padding()

            if user.servicePosted?.allObjects.isEmpty ?? true {
                Text("No posted services available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                List((user.servicePosted?.allObjects as? [Service]) ?? []) { service in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(service.serviceTitle ?? "Untitled Service")
                            .font(.headline)
                        Text(service.serviceDescription ?? "No Description")
                            .font(.subheadline)
                        Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                            .font(.footnote)

                        // Delete Button
                        Button(action: {
                            serviceToDelete = service
                            showingDeleteConfirmation = true
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
