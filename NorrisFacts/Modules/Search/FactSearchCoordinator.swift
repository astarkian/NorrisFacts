//
//  FactSearchCoordinator.swift
//  NorrisFacts
//
//  Created by Alan Paiva on 6/20/20.
//  Copyright © 2020 Alan Paiva. All rights reserved.
//

import UIKit
import RxSwift

protocol FactSearchCoordinatorProtocol: Coordinator {
    func finish(searchResult: SearchResult)
}

final class FactSearchCoordinator: FactSearchCoordinatorProtocol {
    private let parent: UIViewController
    private var navigationController: UINavigationController?
    private let storyboard: StoryboardProtocol
    private let finishHandler: (SearchResult) -> Void

    init(parent: UIViewController, storyboard: StoryboardProtocol, onFinish finishHandler: @escaping (SearchResult) -> Void) {
        self.parent = parent
        self.storyboard = storyboard
        self.finishHandler = finishHandler
    }

    func start() {
        guard let viewController: FactSearchViewController = storyboard.instantiateViewController() else {
            return
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.navigationController = navigationController

        let factProvider = FactProvider()
        let categoryStore = CategoryStore()
        let queryStore = QueryStore()
        let viewModel = FactSearchViewModel(coordinator: self,
                                            factProvider: factProvider,
                                            categoryStore: categoryStore,
                                            queryStore: queryStore,
                                            scheduler: MainScheduler.instance)
        viewController.viewModel = viewModel

        parent.present(navigationController, animated: true, completion: nil)
    }

    func finish(searchResult: SearchResult) {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.finishHandler(searchResult)
        }
    }
}
