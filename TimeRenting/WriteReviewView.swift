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
    @State private var rating: Int = 0 // State to track the rating
    @State private var isSubmitting: Bool = false
    @State private var submissionError: String?
    @State private var showAlert: Bool = false // Correct state for alert

    var body: some View {
        VStack {
            Text("Write a Review")
                .font(.largeTitle)
                .padding()

            Text("For Service: \(service.serviceTitle ?? "Untitled Service")")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom)

            // Rating Section
            VStack {
                Text("Rate this service:")
                    .font(.headline)
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(star <= rating ? .yellow : .gray)
                            .onTapGesture {
                                rating = star
                            }
                    }
                }
                .padding(.vertical)
            }

            // Review Content Section
            TextField("Enter your review here", text: $reviewContent, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 100)
                .padding()

            if let error = submissionError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            // Submit Button
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
                        .background(rating > 0 && !reviewContent.isEmpty ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSubmitting || rating == 0 || reviewContent.isEmpty)

            Spacer()
        }
        .padding()
        .alert("Submit Successfully", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }

    private func submitReview() {
        guard let fromUser = fetchCurrentUser(), let toUser = service.postedByUser else {
            submissionError = "Error: Unable to fetch user information."
            return
        }

        isSubmitting = true
        submissionError = nil

        let newReview = Review(context: viewContext)
        newReview.text = reviewContent // Review text
        newReview.rating = Int16(rating) // Rating as Int16
        newReview.fromUser = fromUser
        newReview.toUser = toUser
        newReview.service = service // Associate the review with the service
        newReview.timestamp = Date()

        do {
            try viewContext.save()
            print("Review submitted successfully.")
            showAlert = true // Show alert for successful submission
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
