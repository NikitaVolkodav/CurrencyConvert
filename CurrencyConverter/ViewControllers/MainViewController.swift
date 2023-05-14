//
//  MainViewController.swift
//  CurrencyConverter
//
//  Created by Nikita Volkodav on 04.03.2023.
//

import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet weak private var currencyConvertLabel: UILabel!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    @IBOutlet weak private var nationalBankButton: UIButton!
    @IBOutlet weak private var mainTableView: UITableView!
    @IBOutlet weak private var dateOfLastUpdateLabel: UILabel!
    @IBOutlet weak private var lastUpdatedDateStackView: UIStackView!
    
    private let searchCurrencyViewController = SearchCurrencyViewController()
    
    private var exchangeRateAPIService: ExchangeRateAPIServiceProtocol?
    private var screenshotService: ScreenshotServiceProtocol?
    private var dateConverterService: DateConverterServiceProtocol?
    private var exchangeRateCacheService: ExchangeRateCacheServiceProtocol?
    private var tableViewCellService: TableViewCellServiceProtocol?
    private var characterService: CharacterServiceProtocol?
    
    private var currencyData = CurrencyData()
    private var initialCurrencies = ["USD", "EUR", "UAH"]
    
    private var portrait: [NSLayoutConstraint] = []
    private var landscape: [NSLayoutConstraint] = []
    private var isPortrait: Bool = false
    
    private var currentInputText = String()
    private var textFieldInputText: String = ""
    private var timer = Timer()
    private var inputTextsDictionary: [IndexPath: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeColorShadowAndColorBorderButton()
        searchCurrencyViewController.delegate = self
        saveExchangeRateDataToCache()
        toggleOrientationConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlertWhenAppIsOpened()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isPortrait = UIDevice.current.orientation.isPortrait
        if isPortrait {
            NSLayoutConstraint.activate(portrait)
            NSLayoutConstraint.deactivate(landscape)
        } else {
            NSLayoutConstraint.activate(landscape)
            NSLayoutConstraint.deactivate(portrait)
        }
        view.layoutIfNeeded()
    }
    
    @IBAction private func toggleSegmentControl(_ sender: UISegmentedControl) {
        let exchangeRateCacheService = ExchangeRateCacheService()
        let exchangeRateAPIService = ExchangeRateAPIService()
        switch sender.selectedSegmentIndex {
        case 0:
            resetTextFields()
            if let cachedData = exchangeRateCacheService.loadExchangeRateDataFromCache() {
                reloadDataInMainTableView(with: cachedData)
            } else {
                exchangeRateAPIService.fetchExchangeRateBaseOnUSD { [weak self] currencyData, error in
                    guard let self = self, let currencyData = currencyData else { return }
                    if let error = error {
                        print("error with fetch exchange rate base on USD sell \(error.localizedDescription)")
                    } else {
                        self.reloadDataInMainTableView(with: currencyData)
                    }
                }
            }
        case 1:
            resetTextFields()
            if let cachedData = exchangeRateCacheService.loadExchangeRateDataFromCache() {
                let updatedRates = cachedData.rates.mapValues { $0 * 1.1 }
                let updatedData = CurrencyData(timestamp: cachedData.timestamp, rates: updatedRates)
                reloadDataInMainTableView(with: updatedData)
            } else {
                exchangeRateAPIService.fetchExchangeRateBaseOnUSD { [weak self] currencyData, error in
                    guard let self = self, let currencyData = currencyData else { return }
                    if let error = error {
                        print("error with fetch exchange rate base on USD buy \(error.localizedDescription)")
                    } else {
                        exchangeRateCacheService.saveExchangeRateDataToCache(currencyData)
                        let updatedRates = currencyData.rates.mapValues { $0 * 1.1 }
                        let updatedData = CurrencyData(timestamp: currencyData.timestamp, rates: updatedRates)
                        self.reloadDataInMainTableView(with: updatedData)
                    }
                }
            }
        default:
            break
        }
    }
    
    @IBAction private func shareExchangeRate(_ sender: UIButton) {
        let screenshotService = ScreenshotService()
        DispatchQueue.main.async {
            let screenshot = screenshotService.takeScreenshot(of: self.view)
            let activityItems = [screenshot as Any]
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction private func addCurrency(_ sender: UIButton) {
        guard let searchCurrencyViewController = storyboard?.instantiateViewController(withIdentifier: "SearchCurrencyViewController") as? SearchCurrencyViewController else { return }
        resetTextFields()
        searchCurrencyViewController.delegate = self
        present(searchCurrencyViewController, animated: true)
    }
    
    func setup(
        screenshotService: ScreenshotServiceProtocol,
        exchangeRateAPIService: ExchangeRateAPIServiceProtocol,
        dateConverterService: DateConverterServiceProtocol,
        exchangeRateCacheService: ExchangeRateCacheServiceProtocol,
        tableViewCellService: TableViewCellServiceProtocol,
        characterService: CharacterServiceProtocol
    ) {
        self.screenshotService = screenshotService
        self.exchangeRateAPIService = exchangeRateAPIService
        self.dateConverterService = dateConverterService
        self.exchangeRateCacheService = exchangeRateCacheService
        self.tableViewCellService = tableViewCellService
        self.characterService = characterService
    }
    
    private func reloadDataInMainTableView(with updateData: CurrencyData) {
        DispatchQueue.main.async {
            self.currencyData = updateData
            self.mainTableView.reloadData()
        }
    }
    
    private func showAlertWhenAppIsOpened() {
        let alert = UIAlertController(title: "Make a choice", message: "Please choice type of converter", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func toggleOrientationConstraints() {
        currencyConvertLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        lastUpdatedDateStackView.translatesAutoresizingMaskIntoConstraints = false
        portrait = [
            currencyConvertLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            contentView.topAnchor.constraint(equalTo: currencyConvertLabel.bottomAnchor, constant: 30),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lastUpdatedDateStackView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20)
        ]
        
        landscape = [
            currencyConvertLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentView.topAnchor.constraint(equalTo: currencyConvertLabel.bottomAnchor, constant: 8),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            lastUpdatedDateStackView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8)
        ]
    }
    
    private func resetTextFields() {
        mainTableView.visibleCells.forEach { cell in
            guard let mainCell = cell as? MainTableViewCell else { return }
            mainCell.textField.text = ""
        }
    }
    
    private func changeColorShadowAndColorBorderButton() {
        contentView.layer.shadowColor = UIColor.gray.cgColor
        nationalBankButton.layer.borderColor = UIColor.link.cgColor
    }
    
    private func saveExchangeRateDataToCache() {
        let exchangeRateAPIService = ExchangeRateAPIService()
        exchangeRateAPIService.fetchExchangeRateBaseOnUSD { [weak self] currencyData, error in
            guard let self = self, let currencyData = currencyData else { return }
            if let error = error {
                print("error with save exchange rate data to cache \(error.localizedDescription)")
            } else {
                self.exchangeRateCacheService?.saveExchangeRateDataToCache(currencyData)
            }
        }
    }
}

// MARK: -  UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        initialCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let mainCell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell()}
        mainCell.currencyTitleLabel.text = initialCurrencies[indexPath.row]
        let dateConverterService = DateConverterService()
        guard let currencyInLabel = mainCell.currencyTitleLabel.text else { mainCell.textField.text = ""
            return mainCell
        }
        mainCell.textField.delegate = self
        mainCell.textField.text = inputTextsDictionary[indexPath]
        mainCell.textField.placeholder = String(format: "%.2f", currencyData.rates[currencyInLabel] ?? 0.00)
        
        self.dateOfLastUpdateLabel.text = dateConverterService.fetchDate(from: currencyData.timestamp)
        
        return mainCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            initialCurrencies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterService = CharacterService()
        guard characterService.isInputOnlyNumbersAndDot(string) else { return false }
        textFieldInputText = textField.text ?? ""
        guard let textRange = Range(range, in: textFieldInputText) else { return false }
        textFieldInputText = textFieldInputText.replacingCharacters(in: textRange, with: string)
        guard let inputValueDouble = Double(textFieldInputText),let rate = currencyData.rates[currentInputText] else { return true }
        let result = inputValueDouble / rate
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
            
            for (key, rateValue) in self.currencyData.rates {
                let updatedRateValue = result * rateValue
                self.currencyData.rates[key] = updatedRateValue
            }
            self.mainTableView.reloadData()
        })
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        let tableViewCellService = TableViewCellService()
        guard let cell = tableViewCellService.findMainTableViewCell(for: textField),
              let currencyTitleLabel = cell.currencyTitleLabel.text else { return }
        currentInputText = currencyTitleLabel
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = nil
    }
}

// MARK: - CurrencySelectionDelegate
extension MainViewController: CurrencySelectionDelegate {
    
    func didSelectCurrency(currency: String) {
        initialCurrencies.append(currency)
        mainTableView.reloadData()
    }
}
