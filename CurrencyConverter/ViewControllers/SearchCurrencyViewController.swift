
import UIKit
import Speech
import AVFoundation

class SearchCurrencyViewController: UIViewController {
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!
    
    private var currencyInfo = CurrencyInfo()
    private var recognizerService = RecognizerService()
    private var isСhangeImageSerchBar = true
    
    var delegate: CurrencySelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizerService.requestAuthorizationRecognizer()
        configureImageSearchBar()
        addedShadowToTableView()
    }
    
    @IBAction private func returnToMainViewController(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func configureImageSearchBar() {
        let imageMicro = UIImage(systemName: "mic.fill")
        searchBar.setImage(imageMicro, for: .bookmark, state: .normal)
    }
    
    private func addedShadowToTableView() {
        tableView.backgroundColor = .clear
        tableView.layer.shadowColor = UIColor.gray.cgColor
        tableView.layer.shadowOpacity = 0.4
        tableView.layer.shadowOffset = .zero
        tableView.layer.shadowRadius = 3
    }
}
// MARK: - UISearchBarDelegate
extension SearchCurrencyViewController: UISearchBarDelegate {
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let imageMicro = UIImage(systemName: "mic.fill")
        let imageStop = UIImage(systemName: "stop.circle")
        if isСhangeImageSerchBar {
            
            searchBar.setImage(imageStop, for: .bookmark, state: .normal)
            recognizerService.startRecognition()
            recognizerService.onSpeechRecognitionResult = { text in
                guard let text = text else { return }
                DispatchQueue.main.async {
                    self.searchBar.text = text
                    self.searchBar(self.searchBar, textDidChange: text)
                    self.tableView.reloadData()
                }
            }
        } else {
            searchBar.setImage(imageMicro, for: .bookmark, state: .normal)
            recognizerService.stopRecognition()
        }
        isСhangeImageSerchBar.toggle()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        lazy var uniqueCurrencies = Set(currencyInfo.currencyModels.flatMap { $0.currency })
        
        currencyInfo.filteredCurrencies = []
        if searchText.isEmpty {
            tableView.reloadData()
            return
        }
        
        for currency in uniqueCurrencies {
            if currency.lowercased().contains(searchText.lowercased()) {
                currencyInfo.filteredCurrencies.append(currency)
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currencyInfo.filteredCurrencies = []
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchCurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard !currencyInfo.filteredCurrencies.isEmpty else {
            if let searchText = searchBar.text?.lowercased(), !searchText.isEmpty {
                let matchingSections = currencyInfo.currencyModels.filter { model in
                    model.currency.contains { currency in
                        currency.lowercased().contains(searchText)
                    }
                }
                return matchingSections.count
            }
            return currencyInfo.currencyModels.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currencyInfo.filteredCurrencies.isEmpty {
        case true:
            return currencyInfo.currencyModels[section].currency.count
        case false:
            return currencyInfo.filteredCurrencies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currenciesCell = tableView.dequeueReusableCell(withIdentifier: "currenciesCell", for: indexPath)
        let currency: String
        
        switch currencyInfo.filteredCurrencies.isEmpty {
        case true:
            currency = currencyInfo.currencyModels[indexPath.section].currency[indexPath.row]
        case false:
            currency = currencyInfo.filteredCurrencies[indexPath.row]
        }
        
        currenciesCell.textLabel?.text = currency
        return currenciesCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch currencyInfo.filteredCurrencies.isEmpty {
        case true:
            return currencyInfo.currencyModels[section].title
        case false:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
        headerView.textLabel?.textColor = UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1)
        guard section == 0 else { return }
        headerView.textLabel?.text = "Popular"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency: String
        switch currencyInfo.filteredCurrencies.isEmpty {
        case true:
            selectedCurrency = currencyInfo.currencyModels[indexPath.section].currency[indexPath.row]
        case false:
            selectedCurrency = currencyInfo.filteredCurrencies[indexPath.row]
        }
        let currencyCode = String(selectedCurrency.prefix(3))
        delegate?.didSelectCurrency(currency: currencyCode)

        dismiss(animated: true)
    }
}
