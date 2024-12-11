//
//  HomeView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Service.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)]
    ) private var services: FetchedResults<Service>

    @FetchRequest(
        entity: Booking.entity(),
        sortDescriptors: []
    ) private var bookings: FetchedResults<Booking> // Fetch all bookings to check their status

    @State private var selectedService: Service? // Tracks the selected service for booking
    @State private var isSearchViewPresented = false // Tracks if SearchView is shown
    @State private var navigateToProfile = false // Tracks navigation to ProfileView
    @ObservedObject var authViewModel: AuthViewModel // Include authViewModel to access user information

    var body: some View {
        NavigationStack {
            VStack {
                // Add a Search Button
                HStack {
                    Spacer()
                    Button(action: {
                        isSearchViewPresented = true // Show the search view
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding()
                }

                if services.isEmpty {
                    Text("No services available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List(services) { service in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)

                            if isServiceBooked(service) {
                                // If the service is booked, show "Already Booked"
                                Text("Already Booked")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            } else {
                                // If the service is not booked, show appropriate button
                                if authViewModel.currentUser == nil {
                                    NavigationLink(
                                        destination: ProfileView(authViewModel: authViewModel),
                                        isActive: $navigateToProfile
                                    ) {
                                        Button("Log in to book") {
                                            navigateToProfile = true
                                        }
                                        .padding()
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                } else {
                                    NavigationLink(destination: BookingView(authViewModel: authViewModel, service: service)) {
                                        Text("Book Now")
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Home")
            .sheet(isPresented: $isSearchViewPresented) {
                SearchView(authViewModel: authViewModel)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                print("Fetched services count: \(services.count)") // Debugging line
            }
        }
    }

    // Function to check if a service is already booked
    private func isServiceBooked(_ service: Service) -> Bool {
        return bookings.contains { $0.service?.id == service.id }
    }
}
