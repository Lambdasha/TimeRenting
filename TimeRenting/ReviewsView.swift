//
//  ReviewsView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/9/24.
//
import SwiftUI
import CoreData

struct ReviewsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var user: User  // User passed from ProfileView

    @State private var reviews: [Review] = []

    var body: some View {
        ScrollView { // Add ScrollView for better layout
            VStack(alignment: .leading, spacing: 10) { // Add spacing between items
                if reviews.isEmpty {
                    Text("No reviews yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 20) // Add some top padding
                } else {

                    ForEach(reviews, id: \.objectID) { review in
                        VStack(alignment: .leading, spacing: 5) { // Add spacing within each review
                            Text("From: \(review.fromUser?.username ?? "Unknown User")")
                                .font(.headline)
                            Text("Rating: \(review.rating) ⭐")
                                .font(.subheadline)
                            Text("Review: \(review.text ?? "No review text")")
                                .font(.body)
                                .foregroundColor(.gray)
                            Divider()
                        }
                        .padding() // Add padding to each review card
                        .background(Color.gray.opacity(0.1)) // Optional: Add background color for better contrast
                        .cornerRadius(8) // Optional: Rounded corners
                    }
                }
            }
            .padding() // Add padding around the entire content
        }
        .onAppear {
            fetchReviewsForUser()
        }
        .navigationTitle("\(user.username ?? "User")'s reviews")
    }

    private func fetchReviewsForUser() {
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "toUser.username == %@", user.username ?? "")
        do {
            reviews = try viewContext.fetch(request)
        } catch {
            print("Error fetching reviews: \(error)")
        }
    }
}
