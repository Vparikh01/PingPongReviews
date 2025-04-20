//
//  ContentView.swift
//  PingPongReviews
//
//  Created by vihaan parikh on 4/20/25.
//

import SwiftUI

struct ContentView: View {
    @State private var reviews:[String]=[]
    @State private var authors:[String]=[]
    @State private var ratings:[String]=[]

    var body: some View {
        NavigationView {
            VStack {
                if reviews.isEmpty {
                    Text("No reviews yet.")
                } else {
                    VStack {
                        List(reviews.indices, id: \.self) { index in
                            let review = reviews[index]
                            let author = authors[index]
                            let rating = Int(ratings[index]) ?? 5

                            VStack(alignment: .leading, spacing: 4) {
                                Text(review)
                                    .font(.headline)

                                Text("by \(author)")
                                    .font(.footnote)
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))


                                HStack(spacing: 2) {
                                    ForEach(0..<rating, id: \.self) { index in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                    ForEach(rating..<5, id: \.self) { _ in
                                        Image(systemName: "star")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }

                        
                    }

                }
            }
            .padding()
            .navigationTitle("Ping Pong App Reviews")
            .onAppear(perform: fetchReviews)
        }
    }
    func fetchReviews(){
        guard let url = URL(string: "https://itunes.apple.com/us/rss/customerreviews/id=6739363110/sortBy=mostRecent/json")
        else { print("URL not valid")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    print("Error fetching data: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(ReviewsResponse.self, from: data)
                    DispatchQueue.main.async {
                        reviews = decoded.feed.entry.map {$0.title.label}
                        authors = decoded.feed.entry.map {$0.author.name.label}
                        ratings = decoded.feed.entry.map {$0.rating.label}
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
                
            }.resume()
    }
}
struct ReviewsResponse: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let entry: [Review]
}

struct Review: Decodable {
    let title: Label
    let author: Name
    let rating: Label

    enum CodingKeys: String, CodingKey {
        case title
        case author
        case rating = "im:rating"
    }
}

struct Name: Decodable {
    let name: Label
}


struct Label: Decodable {
    let label: String
}

#Preview {
    ContentView()
}
