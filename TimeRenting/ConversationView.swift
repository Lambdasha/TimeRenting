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
    let receiver: User // Receiver of the conversation
    @ObservedObject var authViewModel: AuthViewModel // Add authViewModel as a dependency

    @State private var messageContent: String = "" // Holds the input message content

    @FetchRequest var conversationMessages: FetchedResults<Message> // FetchRequest for conversation messages

    init(receiver: User, authViewModel: AuthViewModel) {
        self.receiver = receiver
        self.authViewModel = authViewModel
        
        let senderPredicate = NSPredicate(format: "sender == %@ AND receiver == %@", authViewModel.currentUser!.username ?? "", receiver.username ?? "")
        let receiverPredicate = NSPredicate(format: "sender == %@ AND receiver == %@", receiver.username ?? "", authViewModel.currentUser!.username ?? "")
        
        // Combine predicates to fetch messages between sender and receiver
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [senderPredicate, receiverPredicate])
        
        _conversationMessages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)],
            predicate: compoundPredicate
        )
    }

    var body: some View {
        VStack {
            ScrollView {
                ForEach(conversationMessages) { message in
                    HStack {
                        if message.sender?.username == authViewModel.currentUser?.username {
                            Spacer()
                            Text(message.content ?? "")
                                .padding()
                                .background(Color.blue.opacity(0.8))
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
                }
            }

            Divider()

            // Message Input
            HStack {
                TextField("Enter your message", text: $messageContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: sendMessage) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Conversation with \(receiver.username ?? "Unknown")")
    }

    private func sendMessage() {
        guard !messageContent.isEmpty else { return }

        let newMessage = Message(context: viewContext)
        newMessage.content = messageContent
        newMessage.timestamp = Date()
        newMessage.sender = fetchCurrentUser()
        newMessage.receiver = receiver

        do {
            try viewContext.save()
            messageContent = "" // Clear the input field
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }

    private func fetchCurrentUser() -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", authViewModel.currentUser?.username ?? "")
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching current user: \(error.localizedDescription)")
            return nil
        }
    }
}
