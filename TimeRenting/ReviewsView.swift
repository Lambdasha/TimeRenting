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
        VStack {
            if reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                Text("Reviews:")
                    .font(.title2)
                    .padding(.top)

                ForEach(reviews, id: \.objectID) { review in
                    VStack(alignment: .leading) {
                        Text("From: \(review.fromUser?.username ?? "Unknown User")")
                            .font(.headline)
                        Text("Rating: \(review.rating) ⭐")
                            .font(.subheadline)
                        Text("Review: \(review.text ?? "No review text")")
                            .font(.body)
                            .foregroundColor(.gray)
                        Divider()
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .onAppear {
            fetchReviewsForUser()
        }
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
