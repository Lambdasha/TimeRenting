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
                            Button("Approve") {
                                handleApproval(for: booking)
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button("Reject") {
                                handleRejection(for: booking)
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
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

        do {
            try viewContext.save()
            print("Cancellation approved. Time credits updated.")
        } catch {
            print("Error approving cancellation: \(error.localizedDescription)")
        }
    }

    private func handleRejection(for booking: Booking) {
        // Reject the cancellation
        booking.cancellationApproved = false
        booking.cancellationRequested = false

        do {
            try viewContext.save()
            print("Cancellation rejected.")
        } catch {
            print("Error rejecting cancellation: \(error.localizedDescription)")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
