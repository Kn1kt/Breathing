//
//  ViewController.swift
//  Breathing
//
//  Created by Nikitos on 10.10.2021.
//

import UIKit
import SoundAnalysis
import RxSwift
import RxCocoa

final class ViewController: UIViewController {

    typealias Item = ViewModelItem
    typealias Section = ViewModelVisibleSection
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    final class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return sectionIdentifier(for: section)?.title
        }
    }
    
    // MARK: - Table View
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Button
    
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    
    private var dataSource: DataSource!
    
    private lazy var viewModel: ViewModelProtocol = ViewModel(
        router: Router(sourceController: self),
        audioClassifier: SystemAudioClassifier.singleton
    )
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        setupBindings()
    }

    // MARK: - Setup DataSource
    
    private func setupDataSource() {
        dataSource = .init(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier, for: indexPath) as! ReusableCell
            cell.cellModel = item.cellModel
            return cell
        }
        
        dataSource.defaultRowAnimation = .bottom
    }
    
    
    // MARK: - Setup Bindings
    
    private func setupBindings() {
        viewModel.sections
            .bind(to: dataSource.rx.applySnapshot())
            .disposed(by: disposeBag)
        
        viewModel.isShareEnabled
            .bind(to: shareButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let bindings = ViewModelBindings(
            share: shareButton.rx.tap.asObservable()
        )
        
        disposeBag.insert(viewModel.setup(bindings: bindings))
    }
}

