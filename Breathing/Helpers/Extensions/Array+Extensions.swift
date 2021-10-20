//
//  Array+Extensions.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import Foundation

extension Array where Element: Hashable {
    
    public func reflecting<ChangeElement>(
        difference: CollectionDifference<ChangeElement>,
        itemProvider: (ChangeElement) -> Element
    ) -> Self {
        
        var movedItems = [Int: Element]()
        var target = self
        
        // TODO: - Оптимизировать до O(n + c), где n - self.count, c - difference.count
        difference.forEach { change in
            switch change {
                
            case let .insert(offset: offset, element: element, associatedWith: _):
                guard (target.startIndex...target.endIndex).contains(offset) else {
                    return
                }
                
                let item: Element
                
                if let movedItem = movedItems[offset] {
                    item = movedItem
                    
                } else {
                    item = itemProvider(element)
                }
                
                target.insert(item, at: offset)
                
            case let .remove(offset: offset, element: _, associatedWith: associatedWith):
                guard target.indices.contains(offset) else {
                    return
                }
                
                let element = target.remove(at: offset)
                
                if let movedIndex = associatedWith {
                    movedItems[movedIndex] = element
                }
            }
        }
        
        return target
    }
    
    public func reflectingDifference<ChangeElement>(
        source: [ChangeElement],
        target: [ChangeElement],
        itemProvider: (ChangeElement) -> Element
    ) -> Self where ChangeElement: Hashable {
        
        let difference = target.difference(from: source).inferringMoves()
        
        return reflecting(difference: difference, itemProvider: itemProvider)
    }
    
}
