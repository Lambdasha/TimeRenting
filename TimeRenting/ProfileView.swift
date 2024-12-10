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
    @State private var introduction: String = "" // State variable for user introduction
    
    init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        
        // Set up the FetchRequest for the current user
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
        NavigationView {
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
                    
                    // Introduction Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Introduction")
                            .font(.headline)
                        
                        TextEditor(text: $introduction)
                            .frame(height: 100)
                            .padding(4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onAppear {
                                // Load the introduction from the user entity
                                introduction = user.introduction ?? "" // Assuming 'introduction' exists in User
                            }
                            .onChange(of: introduction) { newValue in
                                // Save changes to the user entity
                                user.introduction = newValue
                                saveUserIntroduction()
                            }
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
                    
                    // Add a button to navigate to ReviewsView
                    if let user = currentUser {
                        NavigationLink(destination: ReviewsView(user: user)) {
                            Text("View Reviews Sent to You")
                                .padding()
                                .foregroundColor(.blue)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    
                    Button("Logout") {
                        authViewModel.logout()
                    }
                    .padding()
                }
            }
            .padding()
            .onAppear {
                // Fetch any data onAppear if necessary
            }
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
                if let currentUser = currentUser {
                    PostedServicesView(user: currentUser, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .sheet(isPresented: $isCancellationRequestsPresented) {
                CancellationRequestsView(user: currentUser!)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        
    }
    
    private func saveUserIntroduction() {
        do {
            try viewContext.save()
            print("Introduction saved successfully.")
        } catch {
            print("Error saving introduction: \(error.localizedDescription)")
        }
    }

}
