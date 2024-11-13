//
//  PostServiceView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 11/11/24.
//


import SwiftUI
import CoreData

struct PostServiceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @ObservedObject var authViewModel: AuthViewModel

    @State private var serviceTitle = ""
    @State private var serviceDescription = ""
    @State private var serviceLocation = ""

    var body: some View {
        VStack {
            TextField("Service Title", text: $serviceTitle)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Description", text: $serviceDescription)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Location", text: $serviceLocation)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Post Service") {
                postService()
                isPresented = false // Dismiss the sheet after posting
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func postService() {
        let newService = Service(context: viewContext)
        newService.serviceTitle = serviceTitle
        newService.serviceDescription = serviceDescription
        newService.serviceLocation = serviceLocation
        newService.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            // Handle error
            print("Error saving service: \(error.localizedDescription)")
        }
    }
}



