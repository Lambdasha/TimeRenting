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

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
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

                            if booking.cancellationRequested == false {
                                Button(action: {
                                    requestCancellation(for: booking)
                                }) {
                                    Text("Request Cancellation")
                                        .foregroundColor(.blue)
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
    }

    private func requestCancellation(for booking: Booking) {
        booking.cancellationRequested = true
        do {
            try viewContext.save()
            print("Cancellation requested successfully.")
        } catch {
            print("Error requesting cancellation: \(error.localizedDescription)")
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
