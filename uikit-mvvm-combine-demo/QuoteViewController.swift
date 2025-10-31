//
//  ViewController.swift
//  uikit-mvvm-combine-demo
//
//  Created by Karlos Aguirre Zaragoza on 28/02/23.
//

import UIKit
import Combine


class QuoteViewController: UIViewController {

    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var quoteLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let vm = QuoteViewModel()
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    private func bind() {
        vm.transform(input: input.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchQuoteDidSucceed(let quote):
                    self?.quoteLbl.text = quote.content
                    self?.authorLbl.text = quote.author
                case .fetchQuoteDidFail(let error):
                    self?.quoteLbl.text = error.localizedDescription
                case .toggleBtn(let isEnabled):
                    self?.refreshBtn.isEnabled = isEnabled
                    isEnabled ? self?.activityIndicator.stopAnimating() : self?.activityIndicator.startAnimating() 
                }
            }.store(in: &cancellables)
    }

    @IBAction func refreshBtnPressed(_ sender: Any) {
        input.send(.refreshBtnDidTap)
    }
}
