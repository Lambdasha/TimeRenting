//
//  ProfileViewForUser.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/8/24.
//
import SwiftUI
import CoreData

struct ProfileViewForUser: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showConversationView = false
    @State private var showLoginAlert = false // To display an alert if the user is not logged in
    @State private var navigateToBookingView = false // Tracks navigation to BookingView
    @State private var selectedService: Service? // Tracks the selected service

    // Fetch services posted by the user
    @FetchRequest var postedServices: FetchedResults<Service>
    // Fetch bookings made by the user
    @FetchRequest var userBookings: FetchedResults<Booking>

    init(user: User, authViewModel: AuthViewModel) {
        self.user = user
        self.authViewModel = authViewModel

        // FetchRequest for services posted by the user
        _postedServices = FetchRequest(
            entity: Service.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)],
            predicate: NSPredicate(format: "postedByUser == %@", user)
        )

        // FetchRequest for bookings made by the user
        _userBookings = FetchRequest(
            entity: Booking.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Booking.timestamp, ascending: false)],
            predicate: NSPredicate(format: "user == %@", user)
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                // User Details Section
                VStack {
                    Text("Profile")
                        .font(.largeTitle)
                        .padding()

                    Text("Username: \(user.username ?? "Unknown")")
                        .font(.headline)

                    Text("Email: \(user.email ?? "No email provided")")
                        .font(.subheadline)
                        .padding()
                }

                Divider()

                // Posted Services Section
                VStack(alignment: .leading) {
                    Text("Services Posted")
                        .font(.headline)
                        .padding(.bottom, 5)

                    if postedServices.isEmpty {
                        Text("No services posted by this user.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        List(postedServices) { service in
                            Button(action: {
                                selectedService = service
                                navigateToBookingView = true
                            }) {
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
                            .buttonStyle(BorderlessButtonStyle()) // Limit the button's click range
                        }
                    }
                }
                .padding(.top, 10)

                // Send Message Button
                Button("Send Message") {
                    if authViewModel.currentUser != nil {
                        showConversationView = true
                    } else {
                        showLoginAlert = true
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("User Profile")
            .alert("Please log in to send a message.", isPresented: $showLoginAlert) {
                Button("OK", role: .cancel) {}
            }
            .navigationDestination(isPresented: $showConversationView) {
                if let loggedInUser = authViewModel.currentUser {
                    ConversationView(receiver: user, authViewModel: authViewModel)
                }
            }
            .navigationDestination(isPresented: $navigateToBookingView) {
                if let selectedService = selectedService {
                    BookingView(authViewModel: authViewModel, service: selectedService)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}
