//
//  ViewReviewView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 12/9/24.
//

import SwiftUI
import CoreData

struct ViewReviewView: View {
    let service: Service
    @Environment(\.managedObjectContext) private var viewContext
    @State private var review: Review? // Single review state

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Review for \(service.serviceTitle ?? "Untitled Service")")
                    .font(.title)
                    .padding(.bottom, 20)

                if let review = review {
                    VStack(alignment: .leading, spacing: 5) { // Add spacing within the review
                        Text("From: \(review.fromUser?.username ?? "Unknown User")")
                            .font(.headline)
                        Text("Rating: \(review.rating) ⭐")
                            .font(.subheadline)
                        if let reviewText = review.text, !reviewText.isEmpty {
                            Text("Review: \(reviewText)")
                                .font(.body)
                                .foregroundColor(.gray)
                        } else {
                            Text("No written review provided.")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        Divider()
                    }
                    .padding() // Add padding to the review card
                    
                    .background(Color.gray.opacity(0.1)) // Optional: Add background color for better contrast
                    .cornerRadius(8) // Optional: Rounded corners
                } else {
                    Text("No review available for this service.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            }
            .padding()
        }
        .onAppear(perform: fetchReview)
    }

    private func fetchReview() {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)

        do {
            // Fetch the first review associated with the service
            review = try viewContext.fetch(fetchRequest).first
        } catch {
            print("Error fetching review: \(error.localizedDescription)")
        }
    }
}
