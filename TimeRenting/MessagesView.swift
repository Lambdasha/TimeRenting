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
    @ObservedObject var authViewModel: AuthViewModel

    @FetchRequest private var messages: FetchedResults<Message>
    @State private var selectedConversation: User? // Tracks the selected conversation
    @State private var isConversationViewPresented = false

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel

        let currentUsername = authViewModel.currentUser?.username ?? ""
        let predicate = NSPredicate(format: "sender.username == %@ OR receiver.username == %@", currentUsername, currentUsername)

        _messages = FetchRequest(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)],
            predicate: currentUsername.isEmpty ? nil : predicate
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.currentUser == nil {
                    Text("No user is logged in.")
                        .foregroundColor(.red)
                        .font(.title2)
                        .padding()
                } else {
                    Text("Messages")
                        .font(.largeTitle)
                        .padding()

                    if messages.isEmpty {
                        Text("No messages yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        let groupedMessages = groupMessagesByUser()

                        List {
                            ForEach(groupedMessages.keys.sorted(), id: \.self) { username in
                                if let firstMessage = groupedMessages[username]?.first,
                                   let otherUser = getOtherUser(from: firstMessage, currentUsername: authViewModel.currentUser?.username ?? "") {
                                    Button(action: {
                                        selectedConversation = otherUser
                                        isConversationViewPresented = true
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(username)
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
            }
            .sheet(isPresented: $isConversationViewPresented) {
                if let user = selectedConversation {
                    ConversationView(receiver: user, authViewModel: authViewModel)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func groupMessagesByUser() -> [String: [Message]] {
        Dictionary(grouping: messages) { message in
            if message.sender?.username == authViewModel.currentUser?.username {
                return message.receiver?.username ?? "Unknown"
            } else {
                return message.sender?.username ?? "Unknown"
            }
        }
    }

    private func getOtherUser(from message: Message, currentUsername: String) -> User? {
        if message.sender?.username == currentUsername {
            return message.receiver
        } else {
            return message.sender
        }
    }
}
