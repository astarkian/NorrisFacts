//
//  FactListViewModel.swift
//  NorrisFacts
//
//  Created by Alan Paiva on 6/20/20.
//  Copyright © 2020 Alan Paiva. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct FactListViewModelInput {
    let searchBarButtonTap: Observable<Void>
}

struct FactListViewModelOutput {
    let items: Driver<[FactListItemViewModel]>
    let isShowingItems: Driver<Bool>
    let message: Driver<String>
}

protocol FactListViewModelProtocol {
    var output: FactListViewModelOutput { get }

    func bind(input: FactListViewModelInput) -> Disposable
    func update(searchResults: [Fact])
}

final class FactListViewModel: FactListViewModelProtocol {
    weak var coordinator: FactListCoordinatorProtocol?

    private let itemsSubject = PublishSubject<[FactListItemViewModel]>()
    private let message = PublishSubject<String>()

    private enum Constants {
        static let emptySearchResults = "No results"
    }

    var output: FactListViewModelOutput {
        .init(
            items: itemsSubject.asDriver(onErrorJustReturn: []),
            isShowingItems: itemsSubject
                .map { !$0.isEmpty }
                .asDriver(onErrorJustReturn: false),
            message: message.asDriver(onErrorJustReturn: "")
        )
    }

    init(coordinator: FactListCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func bind(input: FactListViewModelInput) -> Disposable {
        input
            .searchBarButtonTap
            .subscribe { [weak self] event in
                guard case .next = event else { return }
                self?.coordinator?.startSearch()
            }
    }

    func update(searchResults: [Fact]) {
        if searchResults.isEmpty {
            message.onNext(Constants.emptySearchResults)
        }

        let itemViewModels = searchResults.map { fact in
            FactListItemViewModel(value: fact.value)
        }
        itemsSubject.onNext(itemViewModels)
    }
}
