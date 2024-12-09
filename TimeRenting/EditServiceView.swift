//
//  EditServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/9/24.
//
import SwiftUI
import CoreData

struct EditServiceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode // To dismiss the view
    @State private var serviceTitle: String
    @State private var serviceDescription: String
    @State private var serviceLocation: String

    let service: Service

    init(service: Service) {
        self.service = service
        _serviceTitle = State(initialValue: service.serviceTitle ?? "")
        _serviceDescription = State(initialValue: service.serviceDescription ?? "")
        _serviceLocation = State(initialValue: service.serviceLocation ?? "")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Service")
                .font(.largeTitle)
                .padding()

            TextField("Service Title", text: $serviceTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Description", text: $serviceDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Location", text: $serviceLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: saveChanges) {
                Text("Save Changes")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .padding()
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    private func saveChanges() {
        // Update the service properties
        service.serviceTitle = serviceTitle
        service.serviceDescription = serviceDescription
        service.serviceLocation = serviceLocation

        do {
            try viewContext.save() // Save the changes in Core Data
            print("Service updated successfully.")
            presentationMode.wrappedValue.dismiss() // Dismiss the view after saving
        } catch {
            print("Error saving service updates: \(error.localizedDescription)")
        }
    }
}
