//
//  ReusableCell.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import UIKit

protocol ReusableCell: UITableViewCell, Reusable {
    var cellModel: CellViewModelProtocol! { get set }
}
