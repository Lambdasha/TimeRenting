//
//  MessagesView.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/29/24.
//

import SwiftUI

// Messages View
struct MessagesView: View {
    var body: some View {
        VStack {
            Text("Messages Page")
                .font(.largeTitle)
                .padding()
            Image(systemName: "message.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        .navigationTitle("Messages")
    }
}
