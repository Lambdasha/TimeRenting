//
//  BookedServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/6/24.
import CoreData
import SwiftUI

struct BookedServicesView: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext
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

            // Filter to show only active bookings (not cancelled and not approved for cancellation)
            let activeBookings = bookings.filter { booking in
                booking.cancellationApproved == false && booking.service != nil
            }

            if activeBookings.isEmpty {
                Text("No active bookings available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                List(activeBookings) { booking in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(booking.service?.serviceTitle ?? "Untitled Service")
                            .font(.headline)
                        Text(booking.service?.serviceDescription ?? "No Description")
                            .font(.subheadline)
                        Text("Location: \(booking.service?.serviceLocation ?? "Unknown Location")")
                            .font(.footnote)
                        Text("Booking Date: \(booking.timestamp ?? Date(), formatter: dateFormatter)")
                            .font(.footnote)
                        
                        // Request Cancellation Button
                        if booking.cancellationRequested == false {
                            Button(action: {
                                requestCancellation(for: booking)
                            }) {
                                Text("Request Cancellation")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
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
}
