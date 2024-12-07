//
//  BookingView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/4/24.
//

import SwiftUI
import CoreData

struct BookingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var authViewModel: AuthViewModel
    let service: Service // Receive the selected service

    @State private var bookingConfirmed = false // Tracks if booking is confirmed

    var body: some View {
        VStack(spacing: 20) {
            Text("Book Service")
                .font(.title)
                .padding()

            Text("Service: \(service.serviceTitle ?? "Untitled Service")")
                .font(.headline)

            // Confirm Booking Button
            Button("Confirm Booking") {
                createBooking()
                bookingConfirmed = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if bookingConfirmed {
                Text("Booking confirmed for \(service.serviceTitle ?? "this service")!")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }

    private func createBooking() {
        // Create a new booking instance in Core Data
        let newBooking = Booking(context: viewContext)

        // Set up booking details
        newBooking.timestamp = Date()
        newBooking.service = service // Associate booking with the selected service
        newBooking.id = UUID() // Generate a unique identifier

        // Associate the logged-in user with the booking
        if let currentUser = authViewModel.currentUser {
            newBooking.user = currentUser
        }

        // Attempt to save the booking to the context
        do {
            try viewContext.save()
            print("Booking saved successfully.")
        } catch {
            print("Error saving booking: \(error.localizedDescription)")
        }
    }
}
