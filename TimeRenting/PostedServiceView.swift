//
//  PostedServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/6/24.
//

import CoreData
import SwiftUI

struct PostedServicesView: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            Text("Your Posted Services")
                .font(.largeTitle)
                .padding()

            if user.servicePosted?.allObjects.isEmpty ?? true {
                Text("No posted services available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                List((user.servicePosted?.allObjects as? [Service]) ?? []) { service in
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
        .padding()
    }
}
