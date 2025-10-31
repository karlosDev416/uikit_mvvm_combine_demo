//
//  QuoteService.swift
//  uikit-mvvm-combine-demo
//
//  Created by Karlos Aguirre Zaragoza on 28/02/23.
//

import Foundation
import Combine

protocol QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, Error>
}

class QuoteService: QuoteServiceType {
    
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        let randomNumber = Int.random(in: 1...100)
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(randomNumber)")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error)
            }.map({ $0.data })
            .decode(type: Post.self, decoder: JSONDecoder())
            .map { post in
                return Quote(content: post.title, author: post.body)
            }
            .eraseToAnyPublisher()
        
    }
}

struct Post: Decodable {
    let title: String
    let body: String
}
