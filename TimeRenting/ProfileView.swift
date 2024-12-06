//
//  ProfileView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.

import SwiftUI
import CoreData

struct ProfileView: View {
    @StateObject var authViewModel: AuthViewModel // StateObject for managing the authentication state
    @State private var isPostServicePresented = false // To control the presentation of the post service view
    @State private var isLoginPresented = false // To control the presentation of the login view
    @State private var isSignUpPresented = false // To control the presentation of the sign-up view
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Booking.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Booking.timestamp, ascending: false)]
    ) private var bookings: FetchedResults<Booking> // Fetch all bookings

    var body: some View {
        VStack {
            if let user = authViewModel.currentUser { // Check if the user is logged in
                // Display profile information if the user is logged in
                Text("Welcome, \(user.username ?? "Unknown")!")
                    .font(.largeTitle)

                Text("Email: \(user.email ?? "No email provided")")
                    .padding()

                // Logout Button
                Button("Logout") {
                    authViewModel.logout()
                }
                .padding()

                // Post Service Button
                Button("Post a Service") {
                    isPostServicePresented = true
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                // Display booked services
                Text("Your Booked Services")
                    .font(.headline)
                    .padding(.top, 20)

                if bookings.isEmpty {
                    Text("No booked services available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List(bookings.filter { $0.user?.username == user.username }) { booking in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(booking.service?.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(booking.service?.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(booking.service?.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)
                            Text("Booking Date: \(booking.timestamp ?? Date(), formatter: dateFormatter)")
                                .font(.footnote)
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // Display services posted by the user
                Text("Your Posted Services")
                    .font(.headline)
                    .padding(.top, 20)
                
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
                        }
                        .padding(.vertical, 5)
                    }
                }

            } else {
                // Display message if the user is not logged in
                Text("No user logged in")
                    .font(.title)
                    .padding()

                // Sign-Up Button
                Button("Sign Up") {
                    isSignUpPresented = true
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                // Login Button
                Button("Login") {
                    isLoginPresented = true
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Profile")
        .sheet(isPresented: $isPostServicePresented) {
            PostServiceView(isPresented: $isPostServicePresented, authViewModel: authViewModel)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
        .sheet(isPresented: $isLoginPresented) {
            LoginView(authViewModel: authViewModel, isPresented: $isLoginPresented)
        }
        .sheet(isPresented: $isSignUpPresented) {
            SignUpView(authViewModel: authViewModel, isPresented: $isSignUpPresented)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
