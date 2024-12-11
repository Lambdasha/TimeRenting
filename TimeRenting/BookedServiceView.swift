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
    @State private var navigateToWriteReview: Bool = false
    @State private var selectedService: Service?
    @State private var selectedProvider: User?
    @State private var selectedFilter: BookingFilter = .all // State for filter options
    @State private var refreshTrigger: Bool = false // Trigger for dynamic updates
    @State private var navigateToViewReview: Bool = false // Controls navigation to ViewReviewView

    
    // Alert state
    @State private var showAlert = false
    @State private var selectedBooking: Booking?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    // Enum for filter options
    enum BookingFilter: String, CaseIterable {
        case all = "All Services"
        case unfinished = "Unfinished"
        case finished = "Finished"
    }

    var body: some View {
            VStack {
                // Title
                Text("Your Booked Services")
                    .font(.largeTitle)
                    .padding()

                // Filter Picker
                Picker("Filter Services", selection: $selectedFilter) {
                    ForEach(BookingFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if let currentUser = fetchCurrentUser() {
                    // Apply filter
                    let filteredBookings = applyFilter(for: currentUser)

                    if filteredBookings.isEmpty {
                        Text("No services available for the selected filter.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(filteredBookings, id: \.objectID) { booking in
                                if let service = booking.service {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(service.serviceTitle ?? "Untitled Service")
                                            .font(.headline)
                                        Text(service.serviceDescription ?? "No Description")
                                            .font(.subheadline)
                                        Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                            .font(.footnote)
                                        Text("Booking Date: \(booking.timestamp ?? Date(), formatter: dateFormatter)")
                                            .font(.footnote)

                                        HStack {
                                            if let provider = service.postedByUser {
                                                Button("View Profile") {
                                                    selectedProvider = provider
                                                    navigateToProfile = true
                                                }
                                                .font(.subheadline)
                                                .padding(8)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(5)
                                                .foregroundColor(.blue)
                                                .buttonStyle(BorderlessButtonStyle())
                                            }

                                            Spacer()

                                            // Buttons based on service state
                                            if selectedFilter == .unfinished {
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
                                                .buttonStyle(BorderlessButtonStyle())

                                                Button(action: {
                                                    markAsFinished(booking)
                                                }) {
                                                    Text("Mark as Finished")
                                                        .font(.subheadline)
                                                        .padding(8)
                                                        .background(Color.orange.opacity(0.2))
                                                        .cornerRadius(5)
                                                        .foregroundColor(.orange)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }

                                            if selectedFilter == .finished {
                                                if hasReview(for: service) {
                                                    // Display "View Review" button if a review already exists
                                                    Button(action: {
                                                        selectedService = service
                                                        navigateToViewReview = true
                                                    }) {
                                                        Text("View Review")
                                                            .font(.subheadline)
                                                            .padding(8)
                                                            .background(Color.purple.opacity(0.2))
                                                            .cornerRadius(5)
                                                            .foregroundColor(.purple)
                                                    }
                                                    .buttonStyle(BorderlessButtonStyle())
                                                } else {
                                                    // Display "Write Review" button if no review exists
                                                    Button(action: {
                                                        selectedService = service
                                                        navigateToWriteReview = true
                                                    }) {
                                                        Text("Write Review")
                                                            .font(.subheadline)
                                                            .padding(8)
                                                            .background(Color.green.opacity(0.2))
                                                            .cornerRadius(5)
                                                            .foregroundColor(.green)
                                                    }
                                                    .buttonStyle(BorderlessButtonStyle())
                                                }
                                            }

                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                } else {
                    Text("Error: No logged-in user.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .id(refreshTrigger)
            .navigationDestination(isPresented: $navigateToProfile) {
                if let provider = selectedProvider {
                    ProfileViewForUser(user: provider, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationDestination(isPresented: $navigateToWriteReview) {
                if let service = selectedService {
                    WriteReviewView(authViewModel: authViewModel, service: service)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .alert(isPresented: $showAlert) { // Alert is shown here
                Alert(
                    title: Text("Cancellation Request Sent"),
                    message: Text("Your cancellation request has been sent to the provider."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $navigateToViewReview) {
                            if let service = selectedService {
                                ViewReviewView(service: service)
                                    .environment(\.managedObjectContext, viewContext)
                            }
                        }
    }

    private func applyFilter(for currentUser: User) -> [Booking] {
        switch selectedFilter {
        case .all:
            return bookings.filter { $0.user?.username == currentUser.username && !$0.cancellationApproved }
        case .unfinished:
            return bookings.filter {
                $0.user?.username == currentUser.username &&
                !$0.cancellationApproved &&
                !isServiceFinished(booking: $0)
            }
        case .finished:
            return bookings.filter {
                $0.user?.username == currentUser.username &&
                !$0.cancellationApproved &&
                isServiceFinished(booking: $0)
            }
        }
    }

    private func isServiceFinished(booking: Booking) -> Bool {
        return booking.service?.isFinished ?? false
    }

    private func requestCancellation(for booking: Booking) {
        booking.cancellationRequested = true
        sendCancellationMessage(for: booking)
        do {
            try viewContext.save()
            refreshTrigger.toggle()
            selectedBooking = booking // Store the selected booking for the alert
            showAlert = true // Show the alert
            print("Cancellation requested successfully.")
        } catch {
            print("Error requesting cancellation: \(error.localizedDescription)")
        }
    }
    
    private func hasReview(for service: Service) -> Bool {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)
        
        do {
            let reviews = try viewContext.fetch(fetchRequest)
            return !reviews.isEmpty // Return true if at least one review exists
        } catch {
            print("Error fetching reviews: \(error.localizedDescription)")
            return false
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

    private func markAsFinished(_ booking: Booking) {
        guard let service = booking.service else { return }
        
        // Set the service to finished
        service.isFinished = true

        // Get the provider (postedByUser relationship)
        guard let provider = service.postedByUser else { return }

        // Use the requiredTimeCredits from the service to add time credit to the provider
        let timeCreditToAdd = service.requiredTimeCredits // This uses the value from the service attribute

        // Update the provider's time credit
        provider.timeCredits += timeCreditToAdd // Add the time credit to the provider's balance

        // Save the changes to Core Data
        do {
            try viewContext.save()
            refreshTrigger.toggle()  // This triggers the UI refresh, as needed
            print("Service marked as finished. Added \(timeCreditToAdd) to provider's time credit.")
        } catch {
            print("Error marking service as finished and updating time credit: \(error.localizedDescription)")
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
