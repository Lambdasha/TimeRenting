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
    @State private var navigateToViewReview: Bool = false
    @State private var selectedService: Service? // Tracks the selected service
    @State private var selectedProvider: User? // Tracks the selected service provider
    @State private var selectedFilter: BookingFilter = .all // State for filter option
    @State private var refreshTrigger: Bool = false // Manual state to trigger view refresh

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    // Enum for filter options
    enum BookingFilter: String, CaseIterable {
        case all = "All"
        case unfinished = "Unfinished"
        case finished = "Finished"
    }

    var body: some View {
        NavigationStack {
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
                    // Filter bookings based on selected filter and exclude "Untitled Service"
                    let filteredBookings = applyFilter(for: currentUser)

                    if filteredBookings.isEmpty {
                        Text("No services available for the selected filter.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(filteredBookings, id: \.objectID) { booking in
                                if let title = booking.service?.serviceTitle, !title.isEmpty {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(title)
                                            .font(.headline)
                                        Text(booking.service?.serviceDescription ?? "No Description")
                                            .font(.subheadline)
                                        Text("Location: \(booking.service?.serviceLocation ?? "Unknown Location")")
                                            .font(.footnote)
                                        Text("Booking Date: \(booking.timestamp ?? Date(), formatter: dateFormatter)")
                                            .font(.footnote)

                                        HStack {
                                            if let provider = booking.service?.postedByUser {
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
                                            if isServiceFinished(booking: booking) {
                                                if hasReview(for: booking) {
                                                    Button(action: {
                                                        selectedService = booking.service
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
                                                    Button(action: {
                                                        selectedService = booking.service
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
                                            } else {
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
            .id(refreshTrigger) // Attach `refreshTrigger` to force re-render when updated
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
            .navigationDestination(isPresented: $navigateToViewReview) {
                if let service = selectedService {
                    ViewReviewView(service: service)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func applyFilter(for currentUser: User) -> [Booking] {
        switch selectedFilter {
        case .all:
            return bookings.filter { $0.user?.username == currentUser.username && $0.cancellationApproved == false }
        case .unfinished:
            return bookings.filter {
                $0.user?.username == currentUser.username &&
                $0.cancellationApproved == false &&
                !isServiceFinished(booking: $0)
            }
        case .finished:
            return bookings.filter {
                $0.user?.username == currentUser.username &&
                $0.cancellationApproved == false &&
                isServiceFinished(booking: $0)
            }
        }
    }

    private func isServiceFinished(booking: Booking) -> Bool {
        return booking.service?.isFinished ?? false
    }

    private func hasReview(for booking: Booking) -> Bool {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", booking.service ?? NSNull())
        do {
            let reviews = try viewContext.fetch(fetchRequest)
            return !reviews.isEmpty
        } catch {
            print("Error fetching reviews: \(error.localizedDescription)")
            return false
        }
    }

    private func markAsFinished(_ booking: Booking) {
        guard let service = booking.service else { return }
        service.isFinished = true
        do {
            try viewContext.save()
            refreshTrigger.toggle() // Update the trigger to refresh the view
            print("Service marked as finished.")
        } catch {
            print("Error marking service as finished: \(error.localizedDescription)")
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
