//
//  ContentView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 9/17/24.
//


// ContentView.swift
// TimeRenting

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel() // Create authViewModel here
    @State private var navigateToSecondPage = false // State to control navigation

    var body: some View {
        NavigationStack { // Use NavigationStack instead of NavigationView
            VStack {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Rent your time")
                    .font(.largeTitle)

                // Trigger navigation automatically
                if navigateToSecondPage {
                    NavigationLink(value: "SecondPage") {
                        EmptyView() // Invisible NavigationLink
                    }
                }
            }
            .padding()
            .onAppear {
                // Navigate to the second page after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    navigateToSecondPage = true
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "SecondPage" {
                    SecondPage(authViewModel: authViewModel)
                        .navigationBarBackButtonHidden(true) // Hide the back button
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

