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
        }
        .padding()
    }
}

