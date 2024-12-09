//
//  ProfileViewForUser.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/8/24.
//
import SwiftUI
import CoreData

struct ProfileViewForUser: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch services posted by the user
    @FetchRequest var postedServices: FetchedResults<Service>
    // Fetch bookings made by the user
    @FetchRequest var userBookings: FetchedResults<Booking>

    init(user: User) {
        self.user = user

        // FetchRequest for services posted by the user
        _postedServices = FetchRequest(
            entity: Service.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)],
            predicate: NSPredicate(format: "postedByUser == %@", user)
        )

        // FetchRequest for bookings made by the user
        _userBookings = FetchRequest(
            entity: Booking.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Booking.timestamp, ascending: false)],
            predicate: NSPredicate(format: "user == %@", user)
        )
    }

    var body: some View {
        VStack {
            // User Details Section
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .padding()

                Text("Username: \(user.username ?? "Unknown")")
                    .font(.headline)

                Text("Email: \(user.email ?? "No email provided")")
                    .font(.subheadline)
                    .padding()
            }

            Divider()

            // Posted Services Section
            VStack(alignment: .leading) {
                Text("Services Posted")
                    .font(.headline)
                    .padding(.bottom, 5)

                if postedServices.isEmpty {
                    Text("No services posted by this user.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List(postedServices) { service in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)
                        }
                    }
                }
            }
            .padding(.top, 10)

        }
        .padding()
        .navigationTitle("User Profile")
    }
}

// DateFormatter for formatting dates
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
