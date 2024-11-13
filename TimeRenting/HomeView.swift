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
        entity: Service.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.timestamp, ascending: false)] // Optional: Sort by timestamp to show latest services first
    ) private var services: FetchedResults<Service> // Fetch all Service entries

    var body: some View {
        NavigationView {
            VStack {
                Text("Home Page")
                    .font(.largeTitle)
                    .padding()

                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 20)

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
        }
    }
}

