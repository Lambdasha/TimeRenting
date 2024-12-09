//
//  MessagesView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

import SwiftUI
import CoreData

struct MessagesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Message.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)],
        predicate: nil
    ) private var messages: FetchedResults<Message>
    
    @ObservedObject var authViewModel: AuthViewModel // Pass the AuthViewModel as a dependency
    
    @State private var selectedConversation: User? // Tracks the selected conversation
    @State private var isConversationViewPresented = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Messages")
                    .font(.largeTitle)
                    .padding()

                if messages.isEmpty {
                    Text("No messages yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Group messages by conversations
                    let groupedMessages = Dictionary(grouping: messages) { $0.receiver?.username ?? "" }
                    
                    List {
                        ForEach(groupedMessages.keys.sorted(), id: \.self) { username in
                            if let firstMessage = groupedMessages[username]?.first {
                                Button(action: {
                                    if let user = firstMessage.receiver {
                                        selectedConversation = user
                                        isConversationViewPresented = true
                                    }
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(username.isEmpty ? "Unknown" : username)
                                            .font(.headline)
                                        Text(firstMessage.content ?? "No content")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isConversationViewPresented) {
                if let user = selectedConversation {
                    ConversationView(receiver: user, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}
