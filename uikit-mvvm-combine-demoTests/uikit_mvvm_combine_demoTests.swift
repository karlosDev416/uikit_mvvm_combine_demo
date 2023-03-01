//
//  uikit_mvvm_combine_demoTests.swift
//  uikit-mvvm-combine-demoTests
//
//  Created by Karlos Aguirre Zaragoza on 28/02/23.
//

import XCTest
import Combine
@testable import uikit_mvvm_combine_demo

final class uikit_mvvm_combine_demoTests: XCTestCase {
    
    private var sut: QuoteViewModel!
    private var quoteService: MockQuoteServiceType!
    
    private let vcOutput = PassthroughSubject<QuoteViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        quoteService = MockQuoteServiceType()
        sut = QuoteViewModel(quoteServiceType: quoteService)
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        quoteService = nil
        sut = nil
    }
    
    func testFetchRandomQuotes_onViewDidAppear_isCalled() {
        //given
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "fetch random quotes called")
        //when
        vmOutput.sink { event in }.store(in: &cancellables)
        quoteService.expectation = expectation
        vcOutput.send(.viewDidAppear)
        //then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(quoteService.fetchRandomQuotes, 1)
    }
    
    func testFetchRandomQuotes_onViewDidAppearDidSucceed() {
        // given
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        let quote = Quote(content: "Some description", author: "Apple")
        quoteService.mockedValue = CurrentValueSubject(quote).eraseToAnyPublisher()
        let expectation = XCTestExpectation(description: "fetch random quotes called from viewDidAppear")
        //then
        vmOutput.sink { event in
            switch event {
            case .fetchQuoteDidSucceed(let quote):
                expectation.fulfill()
                XCTAssertEqual(quote.content, "Some description")
                XCTAssertEqual(quote.author, "Apple")
            default:
                break
            }
        }
        .store(in: &cancellables)
        // when
        vcOutput.send(.viewDidAppear)
        wait(for: [expectation], timeout: 0.5)
    }
    
    
    func testFetchRandomQuotes_onViewDidAppearDidFail() {
        // given
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No quotes found!"])
        quoteService.mockedValue = Fail(error: error).eraseToAnyPublisher()
        let expectation = XCTestExpectation(description: "fetch random quotes called from viewDidAppear")
        //then
        vmOutput.sink { event in
            switch event {
            case .fetchQuoteDidFail(let error):
                expectation.fulfill()
                XCTAssertNotNil(error)
                XCTAssertEqual(error.localizedDescription, "No quotes found!")
            default:
                break
            }
        }
        .store(in: &cancellables)
        // when
        vcOutput.send(.viewDidAppear)
        wait(for: [expectation], timeout: 0.5)
    }

}

class MockQuoteServiceType: QuoteServiceType {
    
    var mockedValue: AnyPublisher<Quote, Error>?
    var expectation: XCTestExpectation?
    var fetchRandomQuotes: Int = 0
    
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        expectation?.fulfill()
        fetchRandomQuotes += 1
        return mockedValue ?? Empty().eraseToAnyPublisher()
    }
}
