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

    @FetchRequest private var currentUserFetchRequest: FetchedResults<User>
    private var currentUser: User? {
        currentUserFetchRequest.first
    }

    init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)

        // Set up the FetchRequest
        if let currentUserModel = authViewModel.currentUser {
            _currentUserFetchRequest = FetchRequest(
                entity: User.entity(),
                sortDescriptors: [],
                predicate: NSPredicate(format: "username == %@", currentUserModel.username ?? "")
            )
        } else {
            _currentUserFetchRequest = FetchRequest(entity: User.entity(), sortDescriptors: [])
        }
    }

    var body: some View {
        VStack {
            if authViewModel.currentUser == nil || currentUser == nil {
                // No user logged in
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
            } else if let user = currentUser {
                // Display user profile
                Text("Welcome, \(user.username ?? "Unknown")!")
                    .font(.largeTitle)

                Text("Email: \(user.email ?? "No email provided")")
                    .padding()

                // Display time credits with live updates
                Text("Time Credits: \(user.timeCredits)")
                    .font(.headline)
                    .foregroundColor(.blue)
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
            PostedServicesView(user: currentUser!)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $isCancellationRequestsPresented) {
            CancellationRequestsView(user: currentUser!)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
