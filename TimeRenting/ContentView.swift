//
//  ContentView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 9/17/24.
//
import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel() // Create authViewModel here
    @State private var navigateToSecondPage = false // State to control navigation

    var body: some View {
        NavigationStack { // Main NavigationStack
            VStack {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Rent your time")
                    .font(.largeTitle)
                
                // NavigationLink to SecondPage, triggered by navigateToSecondPage
                NavigationLink(destination: SecondPage(authViewModel: authViewModel), isActive: $navigateToSecondPage) {
                    EmptyView() // This link is programmatically activated
                }
                .hidden() // Hide the NavigationLink from view
            }
            .padding()
            .onAppear {
                navigateToSecondPage = true // Trigger navigation to SecondPage
            }
        }
    }
}

#Preview {
    ContentView()
}
