//
//  BookingView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/4/24.

import SwiftUI
import CoreData

struct BookingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var authViewModel: AuthViewModel
    let service: Service

    @State private var bookingConfirmed = false
    @State private var notEnoughCredits = false
    @State private var selectedProvider: User?
    @State private var currentUser: User?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Book Service")
                    .font(.title)
                    .padding()
                
                Text("Service: \(service.serviceTitle ?? "Untitled Service")")
                    .font(.headline)
                
                Text("Required Time Credits: \(service.requiredTimeCredits)")
                    .font(.subheadline)
                
                // Button to navigate to Service Provider's Profile
                if let serviceProvider = service.postedByUser {
                    NavigationLink(destination: ProfileViewForUser(user: serviceProvider, authViewModel: authViewModel)) {
                        Text("View Service Provider Profile")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                }
                
                if let currentUser = currentUser {
                    if service.postedByUser == currentUser {
                        Text("You cannot book a service you posted.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    } else if bookingConfirmed {
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
            .onAppear {
                currentUser = fetchCoreDataUser()
            }
        }
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

        // Create a conversation and send a confirmation message
        createConversationAndSendMessage(to: service.postedByUser, from: user)

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

    private func createConversationAndSendMessage(to provider: User?, from subscriber: User) {
        guard let provider = provider else {
            print("Error: Service provider not found.")
            return
        }

        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(sender == %@ AND receiver == %@) OR (sender == %@ AND receiver == %@)",
                                             subscriber, provider, provider, subscriber)

        do {
            let existingMessages = try viewContext.fetch(fetchRequest)

            let newMessage = Message(context: viewContext)
            newMessage.content = "Hi \(provider.username ?? "Provider"), I have just booked your service: '\(service.serviceTitle ?? "Untitled Service")'."
            newMessage.timestamp = Date()
            newMessage.sender = subscriber
            newMessage.receiver = provider

            try viewContext.save()
            print(existingMessages.isEmpty ? "Conversation created with initial message." : "New message added to existing conversation.")
        } catch {
            print("Error creating conversation or sending message: \(error.localizedDescription)")
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
