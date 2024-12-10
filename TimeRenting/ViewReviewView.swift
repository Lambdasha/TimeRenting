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
    @State private var reviews: [Review] = []

    var body: some View {
        VStack {
            Text("Reviews for \(service.serviceTitle ?? "Untitled Service")")
                .font(.largeTitle)
                .padding()

            if reviews.isEmpty {
                Text("No reviews available.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                List(reviews.filter { !($0.text?.isEmpty ?? true) }, id: \.self) { review in
                    VStack(alignment: .leading, spacing: 5) {
                        if let reviewer = review.fromUser {
                            Text("Reviewer: \(reviewer.username ?? "Unknown")")
                                .font(.headline)
                        } else {
                            Text("Reviewer: Unknown")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }

                        if let reviewText = review.text, !reviewText.isEmpty {
                            Text(reviewText)
                                .font(.subheadline)
                        }

                        Text("Rating: \(review.rating)/5")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .onAppear(perform: fetchReviews)
        .padding()
    }

    private func fetchReviews() {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)

        do {
            let allReviews = try viewContext.fetch(fetchRequest)
            // Filter out reviews with no content
            reviews = allReviews.filter { !($0.text?.isEmpty ?? true) }
        } catch {
            print("Error fetching reviews: \(error.localizedDescription)")
        }
    }
}
