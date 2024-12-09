//
//  ConversationView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/8/24.
//
import SwiftUI
import CoreData

struct ConversationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let receiver: User
    @ObservedObject var authViewModel: AuthViewModel

    @State private var messageContent: String = ""
    @State private var messages: [Message] = [] // Local storage for messages

    var body: some View {
        VStack {
            // Header displaying recipient username
            HStack {
                Text("Chat with:")
                    .font(.headline)
                Text(receiver.username ?? "Unknown")
                    .font(.title)
                    .bold()
            }
            .padding()
            
            Divider()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(messages, id: \.self) { message in
                            HStack {
                                if message.sender?.username == authViewModel.currentUser?.username {
                                    Spacer()
                                    Text(message.content ?? "")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } else {
                                    Text(message.content ?? "")
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(message) // Assign an ID to each message for scrolling
                        }
                    }
                }
                .onChange(of: messages) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(lastMessage, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastMessage = messages.last {
                        scrollProxy.scrollTo(lastMessage, anchor: .bottom)
                    }
                }
            }

            Divider()

            // New Message Input
            HStack {
                TextField("Enter your message", text: $messageContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    sendMessage()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Conversation")
        .onAppear {
            fetchMessages()
        }
    }

    private func fetchMessages() {
        guard let currentUser = fetchCurrentUser() else {
            print("Error: No logged-in user.")
            return
        }

        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                NSPredicate(format: "sender == %@ AND receiver == %@", currentUser, receiver),
                NSPredicate(format: "sender == %@ AND receiver == %@", receiver, currentUser)
            ]
        )

        do {
            messages = try viewContext.fetch(fetchRequest)
            print("Fetched \(messages.count) messages.")
        } catch {
            print("Error fetching messages: \(error.localizedDescription)")
        }
    }

    private func sendMessage() {
        guard let sender = fetchCurrentUser(), !messageContent.isEmpty else {
            print("Error: Missing sender or message content.")
            return
        }

        let newMessage = Message(context: viewContext)
        newMessage.content = messageContent
        newMessage.timestamp = Date()
        newMessage.sender = sender
        newMessage.receiver = receiver

        do {
            try viewContext.save()
            messageContent = "" // Clear input
            fetchMessages() // Refresh messages after sending
        } catch {
            print("Error saving message: \(error.localizedDescription)")
        }
    }

    private func fetchCurrentUser() -> User? {
        guard let currentUsername = authViewModel.currentUser?.username else {
            print("Error: No logged-in user.")
            return nil
        }

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", currentUsername)
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching current user: \(error.localizedDescription)")
            return nil
        }
    }
}
