//
//  Rx+DiffableDataSources.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import UIKit
import RxSwift

// MARK: - Models

public protocol DiffableSection: Hashable {
    
    associatedtype DiffableItem: Hashable
    
    var items: [DiffableItem] { get }
    
}

// MARK: - Array

public extension Array where Element: DiffableSection {
    
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Element, Element.DiffableItem> {
        return self.reduce(into: .init()) { snapshot, section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.items)
        }
    }
    
}

// MARK: - Reactive

public extension Reactive {
        
    func applySnapshot<S>(
        animatingDifferences: Bool = true
    ) -> Binder<[S]>
    where
        S: DiffableSection,
        Base: UITableViewDiffableDataSource<S, S.DiffableItem>
    {
        return Binder(self.base, scheduler: MainScheduler.asyncInstance) { dataSource, sections in
            dataSource.apply(sections.makeSnapshot(), animatingDifferences: animatingDifferences)
        }
    }
    
}
