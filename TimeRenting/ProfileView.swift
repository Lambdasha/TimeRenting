//
//  ProfileView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
// ProfileView.swift

import SwiftUI
import CoreData

struct ProfileView: View {
    @StateObject var authViewModel: AuthViewModel
    @State private var isPostServicePresented = false
    @State private var isLoginPresented = false
    @State private var isSignUpPresented = false
    @State private var isBookedServicesPresented = false
    @State private var isPostedServicesPresented = false
    @State private var isCancellationRequestsPresented = false
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            if let user = authViewModel.currentUser { // Check if the user is logged in
                Text("Welcome, \(user.username ?? "Unknown")!")
                    .font(.largeTitle)

                Text("Email: \(user.email ?? "No email provided")")
                    .padding()

                Button("Logout") {
                    authViewModel.logout()
                }
                .padding()

                Button("Post a Service") {
                    isPostServicePresented = true
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button("View Your Booked Services") {
                    isBookedServicesPresented = true
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button("View Your Posted Services") {
                    isPostedServicesPresented = true
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button("View Cancellation Requests") {
                    isCancellationRequestsPresented = true
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            } else {
                Text("No user logged in")
                    .font(.title)
                    .padding()

                Button("Sign Up") {
                    isSignUpPresented = true
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button("Login") {
                    isLoginPresented = true
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $isPostServicePresented) {
            PostServiceView(isPresented: $isPostServicePresented, authViewModel: authViewModel)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $isLoginPresented) {
            LoginView(authViewModel: authViewModel, isPresented: $isLoginPresented)
        }
        .sheet(isPresented: $isSignUpPresented) {
            SignUpView(authViewModel: authViewModel, isPresented: $isSignUpPresented)
        }
        .sheet(isPresented: $isBookedServicesPresented) {
            BookedServicesView(authViewModel: authViewModel)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $isPostedServicesPresented) {
            PostedServicesView(user: authViewModel.currentUser!)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $isCancellationRequestsPresented) {
            CancellationRequestsView(user: authViewModel.currentUser!)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
