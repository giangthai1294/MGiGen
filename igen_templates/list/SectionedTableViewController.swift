import UIKit
import Reusable
import RxDataSources

final class {{ name }}ViewController: UIViewController, BindableType {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: LoadMoreTableView!

    // MARK: - Properties
    
    var viewModel: {{ name }}ViewModel!

    fileprivate typealias {{ model_name }}SectionModel = SectionModel<String, {{ model_name }}>
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<{{ model_name }}SectionModel>!

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    deinit {
        logDeinit()
    }

    // MARK: - Methods
    
    private func configView() {
        tableView.do {
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
            $0.register(cellType: {{ model_name }}Cell.self)
        }
        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = {{ name }}ViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: tableView.refreshTrigger,
            loadMoreTrigger: tableView.loadMoreTrigger,
            select{{ model_name }}Trigger: tableView.rx.itemSelected.asDriver()
        )

        let output = viewModel.transform(input)

        dataSource = RxTableViewSectionedReloadDataSource<{{ model_name }}SectionModel>(
            configureCell: { (_, tableView, indexPath, {{ model_variable }}) -> UITableViewCell in
                return tableView.dequeueReusableCell(for: indexPath, cellType: {{ model_name }}Cell.self).then {
                    $0.bindViewModel({{ model_name }}ViewModel({{ model_variable }}: {{ model_variable }}))
                }
            },
            titleForHeaderInSection: { dataSource, section in
                return dataSource.sectionModels[section].model
            })
        
        output.{{ model_variable }}Sections
            .map {
                $0.map { section in
                    {{ model_name }}SectionModel(model: section.header, items: section.{{ model_variable }}List)
                }
            }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        output.error
            .drive(rx.error)
            .disposed(by: rx.disposeBag)
        output.loading
            .drive(rx.isLoading)
            .disposed(by: rx.disposeBag)
        output.refreshing
            .drive(tableView.refreshing)
            .disposed(by: rx.disposeBag)
        output.loadingMore
            .drive(tableView.loadingMore)
            .disposed(by: rx.disposeBag)
        output.fetchItems
            .drive()
            .disposed(by: rx.disposeBag)
        output.selected{{ model_name }}
            .drive()
            .disposed(by: rx.disposeBag)
        output.isEmptyData
            .drive()
            .disposed(by: rx.disposeBag)
    }

}

// MARK: - Binders
extension {{ name }}ViewController {

}

// MARK: - UITableViewDelegate
extension {{ name }}ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension {{ name }}ViewController: StoryboardSceneBased {
    static var sceneStoryboard = UIStoryboard()
}
