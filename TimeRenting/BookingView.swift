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
    let service: Service

    @State private var bookingConfirmed = false
    @State private var notEnoughCredits = false // Tracks if the user lacks sufficient time credits

    var body: some View {
        VStack(spacing: 20) {
            Text("Book Service")
                .font(.title)
                .padding()

            Text("Service: \(service.serviceTitle ?? "Untitled Service")")
                .font(.headline)

            Text("Required Time Credits: \(service.requiredTimeCredits)")
                .font(.subheadline)

            if let currentUser = fetchCoreDataUser() {
                if bookingConfirmed {
                    Text("Booking confirmed for \(service.serviceTitle ?? "this service")!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else if notEnoughCredits {
                    Text("Not enough time credits.")
                        .foregroundColor(.red)
                } else {
                    Button("Confirm Booking") {
                        handleBooking(for: currentUser)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                Text("Please login to book this service.")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    private func handleBooking(for user: User) {
        let requiredCredits = service.requiredTimeCredits

        guard user.timeCredits >= requiredCredits else {
            notEnoughCredits = true
            bookingConfirmed = false
            return
        }

        // Deduct time credits and create booking
        user.timeCredits -= requiredCredits
        createBooking(for: user)

        // Update flags
        bookingConfirmed = true
        notEnoughCredits = false
    }

    private func createBooking(for user: User) {
        let newBooking = Booking(context: viewContext)
        newBooking.timestamp = Date()
        newBooking.service = service
        newBooking.user = user

        do {
            try viewContext.save()
            print("Booking saved successfully.")
        } catch {
            print("Error saving booking: \(error.localizedDescription)")
        }
    }

    private func fetchCoreDataUser() -> User? {
        guard let currentUserModel = authViewModel.currentUser else {
            return nil
        }

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", currentUserModel.username ?? "")

        do {
            return try viewContext.fetch(fetchRequest).first
        } catch {
            print("Error fetching Core Data user: \(error.localizedDescription)")
            return nil
        }
    }
}
