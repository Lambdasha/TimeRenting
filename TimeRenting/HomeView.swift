//
//  HomeView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Service.entity(), // Ensure this matches your Core Data model entity name
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)] // Optional: Sort by timestamp
    ) private var services: FetchedResults<Service> // Fetch all Service entries

    var body: some View {
        NavigationView {
            VStack {
                if services.isEmpty {
                    Text("No services available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    List(services) { service in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(service.serviceTitle ?? "Untitled Service")
                                .font(.headline)
                            Text(service.serviceDescription ?? "No Description")
                                .font(.subheadline)
                            Text("Location: \(service.serviceLocation ?? "Unknown Location")")
                                .font(.footnote)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Home")
            .onAppear {
                print("Fetched services count: \(services.count)")  // Debugging line to check how many services are fetched
            }
        }
    }
}

