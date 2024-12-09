//
//  CancellationRequestsView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/8/24.
//
import SwiftUI
import CoreData

struct CancellationRequestsView: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var cancellationRequests: FetchedResults<Booking>

    init(user: User) {
        self.user = user
        _cancellationRequests = FetchRequest(
            entity: Booking.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Booking.timestamp, ascending: false)],
            predicate: NSPredicate(format: "service.postedByUser == %@ AND cancellationRequested == true", user)
        )
    }

    var body: some View {
        VStack {
            Text("Cancellation Requests")
                .font(.largeTitle)
                .padding()

            if cancellationRequests.isEmpty {
                Text("No cancellation requests.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                List(cancellationRequests) { booking in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Service: \(booking.service?.serviceTitle ?? "Unknown Service")")
                            .font(.headline)
                        Text("User: \(booking.user?.username ?? "Unknown User")")
                            .font(.subheadline)
                        Text("Requested On: \(booking.timestamp ?? Date(), formatter: dateFormatter)")
                            .font(.footnote)

                        HStack {
                            // Approve Button
                            Button(action: {
                                handleApproval(for: booking)
                            }) {
                                Text("Approve")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(5)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Limit click region

                            Spacer()

                            // Reject Button
                            Button(action: {
                                handleRejection(for: booking)
                            }) {
                                Text("Reject")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(5)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Limit click region
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
    }

    private func handleApproval(for booking: Booking) {
        guard let service = booking.service, let bookedUser = booking.user else {
            print("Error: Missing service or user.")
            return
        }

        // Increment the time credits of the user who booked the service
        bookedUser.timeCredits += service.requiredTimeCredits
        booking.cancellationApproved = true
        booking.cancellationRequested = false

        // Disassociate the service from the booking to mark it as canceled
        booking.service = nil

        // Send a message to notify the subscriber of the approval
        sendMessage(
            from: user,
            to: bookedUser,
            content: "Your cancellation request for the service '\(service.serviceTitle ?? "Unknown Service")' has been approved."
        )

        do {
            try viewContext.save()
            print("Cancellation approved. Time credits updated.")
        } catch {
            print("Error approving cancellation: \(error.localizedDescription)")
        }
    }

    private func handleRejection(for booking: Booking) {
        guard let bookedUser = booking.user, let service = booking.service else {
            print("Error: Missing service or user.")
            return
        }

        // Reject the cancellation
        booking.cancellationApproved = false
        booking.cancellationRequested = false

        // Send a message to notify the subscriber of the rejection
        sendMessage(
            from: user,
            to: bookedUser,
            content: "Your cancellation request for the service '\(service.serviceTitle ?? "Unknown Service")' has been rejected."
        )

        do {
            try viewContext.save()
            print("Cancellation rejected.")
        } catch {
            print("Error rejecting cancellation: \(error.localizedDescription)")
        }
    }

    private func sendMessage(from sender: User, to receiver: User, content: String) {
        let newMessage = Message(context: viewContext)
        newMessage.content = content
        newMessage.timestamp = Date()
        newMessage.sender = sender
        newMessage.receiver = receiver

        do {
            try viewContext.save()
            print("Message sent: \(content)")
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
