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
    let service: Service // The service being booked

    @State private var bookingConfirmed = false // Tracks booking confirmation

    var body: some View {
        VStack(spacing: 20) {
            Text("Book Service")
                .font(.title)
                .padding()

            Text("Service: \(service.serviceTitle ?? "Untitled Service")")
                .font(.headline)

            Button("Confirm Booking") {
                createBooking()
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
        // Create a new booking instance
        let newBooking = Booking(context: viewContext)
        newBooking.timestamp = Date()
        newBooking.service = service // Associate the booking with the service
        newBooking.id = UUID()

        // Fetch the current logged-in Core Data user
        guard let coreDataUser = fetchCoreDataUser() else {
            print("Error: Logged-in user not found in Core Data.")
            return
        }
        newBooking.user = coreDataUser

        // Attempt to save the booking
        do {
            try viewContext.save()
            print("Booking saved successfully.")
            bookingConfirmed = true

            // Create and display the conversation
            createAndDisplayConversation(for: coreDataUser, with: service.postedByUser)
        } catch {
            print("Error saving booking: \(error.localizedDescription)")
        }
    }

    private func fetchCoreDataUser() -> User? {
        guard let currentUserModel = authViewModel.currentUser else {
            print("No logged-in user found in AuthViewModel.")
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

    private func createAndDisplayConversation(for user: User, with provider: User?) {
        guard let provider = provider else {
            print("Error: Service provider not found.")
            return
        }

        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(sender == %@ AND receiver == %@) OR (sender == %@ AND receiver == %@)",
                                             user, provider, provider, user)

        do {
            let existingMessages = try viewContext.fetch(fetchRequest)

            if existingMessages.isEmpty {
                let welcomeMessage = Message(context: viewContext)
                welcomeMessage.content = "Welcome to your conversation!"
                welcomeMessage.timestamp = Date()
                welcomeMessage.sender = provider
                welcomeMessage.receiver = user

                try viewContext.save()
                print("Conversation created successfully.")
            } else {
                print("Conversation already exists.")
            }
        } catch {
            print("Error creating conversation: \(error.localizedDescription)")
        }
    }
}
