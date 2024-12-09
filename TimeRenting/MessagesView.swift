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
        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
    ) private var messages: FetchedResults<Message> // Fetch all messages
    
    @ObservedObject var authViewModel: AuthViewModel // Pass the AuthViewModel as a dependency
    
    @State private var receiverUsername: String = ""
    @State private var messageContent: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Message List
                if messages.isEmpty {
                    Text("No messages yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(messages) { message in
                        VStack(alignment: .leading) {
                            Text("From: \(message.sender?.username ?? "Unknown")")
                                .font(.headline)
                            Text("To: \(message.receiver?.username ?? "Unknown")")
                                .font(.subheadline)
                            Text("Message: \(message.content ?? "No content")")
                                .font(.body)
                            Text("\(message.timestamp ?? Date(), formatter: dateFormatter)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // New Message Section
                Divider()
                VStack(alignment: .leading) {
                    TextField("Recipient Username", text: $receiverUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    
                    TextField("Your Message", text: $messageContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    
                    Button("Send Message") {
                        sendMessage()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Messages")
        }
    }
    
    private func sendMessage() {
        guard !receiverUsername.isEmpty, !messageContent.isEmpty else {
            print("Recipient or message content is empty.")
            return
        }

        let newMessage = Message(context: viewContext)
        newMessage.content = messageContent
        newMessage.timestamp = Date()

        // Fetch sender and receiver from Core Data
        if let currentUser = fetchCurrentUser() {
            newMessage.sender = currentUser
        } else {
            print("Error: Current user not found.")
            return
        }

        if let receiver = fetchUser(byUsername: receiverUsername) {
            newMessage.receiver = receiver
        } else {
            print("Error: Receiver not found.")
            return
        }

        do {
            try viewContext.save()
            messageContent = "" // Clear input fields
            receiverUsername = ""
            print("Message sent successfully.")
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    private func fetchCurrentUser() -> User? {
        guard let currentUserModel = authViewModel.currentUser else {
            print("No logged-in user.")
            return nil
        }

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", currentUserModel.username ?? "")

        do {
            let results = try viewContext.fetch(request)
            return results.first
        } catch {
            print("Error fetching current user: \(error.localizedDescription)")
            return nil
        }
    }

    private func fetchUser(byUsername username: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let results = try viewContext.fetch(request)
            return results.first
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
