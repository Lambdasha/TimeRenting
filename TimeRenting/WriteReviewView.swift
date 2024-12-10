//
//  WriteReviewView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/9/24.
//

import SwiftUI
import CoreData

struct WriteReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss // Handles navigation back
    @ObservedObject var authViewModel: AuthViewModel
    let service: Service

    @State private var reviewContent: String = ""
    @State private var isSubmitting: Bool = false
    @State private var submissionError: String?

    var body: some View {
        VStack {
            Text("Write a Review")
                .font(.largeTitle)
                .padding()

            TextField("Enter your review here", text: $reviewContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let error = submissionError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            Button(action: submitReview) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Text("Submit Review")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSubmitting || reviewContent.isEmpty)

            Spacer()
        }
        .padding()
    }

    private func submitReview() {
        guard let fromUser = fetchCurrentUser(), let toUser = service.postedByUser else {
            submissionError = "Error: Unable to fetch user information."
            return
        }

        isSubmitting = true
        submissionError = nil

        let newReview = Review(context: viewContext)
        newReview.text = reviewContent // Ensure Core Data has a `content` field for the review
        newReview.fromUser = fromUser
        newReview.toUser = toUser
        newReview.service = service // Associate the review with the service
        newReview.timestamp = Date()

        do {
            try viewContext.save()
            print("Review submitted successfully.")
            dismiss() // Automatically go back to the previous page
        } catch {
            submissionError = "Failed to submit review. Please try again."
            print("Error submitting review: \(error.localizedDescription)")
        }

        isSubmitting = false
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
