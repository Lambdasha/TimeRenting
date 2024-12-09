//
//  BookedServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/6/24.
// BookedServicesView.swift

import CoreData
import SwiftUI

struct BookedServicesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var authViewModel: AuthViewModel
    @FetchRequest(
        entity: Booking.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Booking.timestamp, ascending: false)]
    ) private var bookings: FetchedResults<Booking>

    @State private var navigateToProfile: Bool = false
    @State private var selectedProvider: User? // Tracks the selected service provider

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Booked Services")
                    .font(.largeTitle)
                    .padding()

                if let currentUser = fetchCurrentUser() {
                    let userBookings = bookings.filter { $0.user?.username == currentUser.username && $0.cancellationApproved == false }

                    if userBookings.isEmpty {
                        Text("No active bookings available.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        List(userBookings, id: \.objectID) { booking in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(booking.service?.serviceTitle ?? "Untitled Service")
                                    .font(.headline)
                                Text(booking.service?.serviceDescription ?? "No Description")
                                    .font(.subheadline)
                                Text("Location: \(booking.service?.serviceLocation ?? "Unknown Location")")
                                    .font(.footnote)
                                Text("Booking Date: \(booking.timestamp ?? Date(), formatter: dateFormatter)")
                                    .font(.footnote)

                                HStack {
                                    if let provider = booking.service?.postedByUser {
                                        Button("View Profile") {
                                            selectedProvider = provider
                                            navigateToProfile = true
                                        }
                                        .font(.subheadline)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(5)
                                        .foregroundColor(.blue)
                                        .buttonStyle(BorderlessButtonStyle()) // Limit button click range
                                    }

                                    Spacer()

                                    if booking.cancellationRequested == false {
                                        Button(action: {
                                            requestCancellation(for: booking)
                                        }) {
                                            Text("Request Cancellation")
                                                .font(.subheadline)
                                                .padding(8)
                                                .background(Color.red.opacity(0.2))
                                                .cornerRadius(5)
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(BorderlessButtonStyle()) // Limit button click range
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                } else {
                    Text("Error: No logged-in user.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToProfile) {
                if let provider = selectedProvider {
                    ProfileViewForUser(user: provider, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func requestCancellation(for booking: Booking) {
        booking.cancellationRequested = true
        sendCancellationMessage(for: booking) // Send message to the provider
        do {
            try viewContext.save()
            print("Cancellation requested successfully.")
        } catch {
            print("Error requesting cancellation: \(error.localizedDescription)")
        }
    }

    private func sendCancellationMessage(for booking: Booking) {
        guard let provider = booking.service?.postedByUser,
              let subscriber = booking.user else {
            print("Error: Missing provider or subscriber.")
            return
        }

        let messageContent = "The subscriber '\(subscriber.username ?? "Unknown")' has requested a cancellation for the service '\(booking.service?.serviceTitle ?? "Unknown Service")'."
        
        let newMessage = Message(context: viewContext)
        newMessage.content = messageContent
        newMessage.timestamp = Date()
        newMessage.sender = subscriber
        newMessage.receiver = provider

        do {
            try viewContext.save()
            print("Cancellation message sent to provider.")
        } catch {
            print("Error sending cancellation message: \(error.localizedDescription)")
        }
    }

    private func fetchCurrentUser() -> User? {
        guard let currentUsername = authViewModel.currentUser?.username else {
            print("Error: No logged-in user.")
            return nil
        }

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", currentUsername)

        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching current user: \(error.localizedDescription)")
            return nil
        }
    }
}
