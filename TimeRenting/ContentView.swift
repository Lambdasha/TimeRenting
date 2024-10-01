//
//  ContentView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 9/17/24.
//

import SwiftUI

// First Page (Main Page)
struct ContentView: View {
    var body: some View {
        NavigationView { // NavigationView to enable navigation
            VStack {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Rent your time")
                    .font(.largeTitle)
                
                // NavigationLink to go to the second page
                NavigationLink(destination: SecondPage()) {
                    Text("Get started")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// Second Page (Destination Page)
struct SecondPage: View {
    var body: some View {
        TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    
                    MessagesView()
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Messages")
                        }
                    
                    MeView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Me")
                        }
                }
        .navigationTitle("Second Page") // Title for the second page
        .padding()
    }
}
struct HomeView: View {
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
            }
            .navigationTitle("Home")
        }
    }
}

// Messages View
struct MessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Messages Page")
                    .font(.largeTitle)
                    .padding()
                Image(systemName: "message.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .navigationTitle("Messages")
        }
    }
}

// Me View
struct MeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Me Page")
                    .font(.largeTitle)
                    .padding()
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .navigationTitle("Me")
        }
    }
}


#Preview {
    ContentView()
}


