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
                        ForEach(sortedUsernames(from: groupedMessages), id: \.self) { username in
                            if let firstMessage = groupedMessages[username]?.first,
                               let otherUser = getOtherUser(from: firstMessage, currentUsername: authViewModel.currentUser?.username ?? "") {
                                NavigationLink(destination: ConversationView(receiver: otherUser, authViewModel: authViewModel).environment(\.managedObjectContext, viewContext)
                                    .onAppear {
                                        markMessagesAsRead(with: otherUser)
                                    }
                                ) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(username)
                                                .font(.headline)
                                            Text(firstMessage.content ?? "No content")
                                                .font(.subheadline)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        if !(firstMessage.isRead ?? true) && firstMessage.receiver?.username == authViewModel.currentUser?.username {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                }
                            }
                        }
                    }
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

    private func sortedUsernames(from groupedMessages: [String: [Message]]) -> [String] {
        groupedMessages.keys.sorted { username1, username2 in
            guard let firstMessage1 = groupedMessages[username1]?.first,
                  let firstMessage2 = groupedMessages[username2]?.first else {
                return false
            }
            return (firstMessage1.timestamp ?? Date()) > (firstMessage2.timestamp ?? Date())
        }
    }

    private func getOtherUser(from message: Message, currentUsername: String) -> User? {
        if message.sender?.username == currentUsername {
            return message.receiver
        } else {
            return message.sender
        }
    }

    private func markMessagesAsRead(with otherUser: User) {
        let currentUser = authViewModel.currentUser
        for message in messages where message.receiver == currentUser && message.sender == otherUser && !(message.isRead ?? true) {
            message.isRead = true
        }
        do {
            try viewContext.save()
        } catch {
            print("Error marking messages as read: \(error.localizedDescription)")
        }
    }
}
