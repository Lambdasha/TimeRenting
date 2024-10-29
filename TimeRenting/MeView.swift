//
//  MeView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

import SwiftUI

struct MeView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            if let _ = authViewModel.currentUser {
                // Show ProfileView if the user is logged in
                ProfileView(authViewModel: authViewModel)
            } else {
                // Otherwise, show sign-up and login options
                VStack {
                    Image(systemName: "clock")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Rent your time")

                    NavigationLink(destination: SignUpView(authViewModel: authViewModel)) {
                        Text("Sign Up")
                    }
                    .padding()

                    NavigationLink(destination: LoginView(authViewModel: authViewModel)) {
                        Text("Login")
                    }
                    .padding()
                }
            }
        }
        .padding()
        .navigationTitle("Me")
        .onAppear {
            // Optional: additional setup if needed on appearing
        }
    }
}
