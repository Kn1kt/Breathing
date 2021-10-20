//
//  ViewModelItem.swift
//  Breathing
//
//  Created by Nikitos on 14.10.2021.
//

import Foundation

struct ViewModelItem: Hashable, UUIDIdentifable {
    
    let cellModel: CellViewModelProtocol & UUIDIdentifable
    
    var identifier: UUID { cellModel.identifier }
    var cellIdentifier: String { cellModel.cellIdentifier }
}
