//
//  ViewController.swift
//  News API
//
//  Created by user on 10/26/21.
//

import UIKit
import Network

class ViewController: UIViewController {
    private var api_url = "https://newsapi.org/v2/top-headlines?apiKey=yourKey&pagesize=100&country=ca"
    private let cellId = "Cell"
    private let countryList = ["Canada", "United States", "Great Britan", "China", "Hong Kong", "Taiwan"]
    
    private var articleObjList = [ArticleObject]()
    private var filteredList = [ArticleObject]()
    private var sourceNameList = [String]()
    
    private let screenWidth = UIScreen.main.bounds.width
    private var itemsPerRow = 1 //for ipad's two columns support
    private var titleTextSize = 24
    
    private let networkMonitor = NetworkMonitor.shared
    
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var mediumIndicator: UIActivityIndicatorView! {
        didSet{
            mediumIndicator.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            mediumIndicator.isHidden = true
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        if !networkMonitor.isConnected {
            self.showMsg(msg: "No internet connection")
        }else {
            getArticlesFromApi(urlString: api_url)
        }
        sourcesBn.title = "Source Filter"
    }
    
    @IBOutlet weak var columnSwitch: UISwitch!
    @IBOutlet weak var columnLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var sourcesBn: UIBarButtonItem!
    @IBAction func sourceBnClick(_ sender: Any) {
        guard !sourceNameList.isEmpty  else {
            return
        }
        
        let alert = UIAlertController(title: "Source Filter", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "All", style: UIAlertAction.Style.default, handler: { action in
            self.filterAction(sourceName: "All")
        }))
        for sourceName in sourceNameList {
            alert.addAction(UIAlertAction(title: sourceName, style: UIAlertAction.Style.default, handler: { action in
                self.filterAction(sourceName: sourceName)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var countriesBn: UIButton!
    @IBAction func countriesBnClick(_ sender: Any) {
        let alert = UIAlertController(title: "Countries", message: "", preferredStyle: UIAlertController.Style.alert)
        
        for country in countryList {
            alert.addAction(UIAlertAction(title: country, style: UIAlertAction.Style.default, handler: { action in
                self.countrySelected(country: country)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: tab buttons
    @IBAction func homeBnClick(_ sender: Any) {
        api_url = "https://newsapi.org/v2/top-headlines?apiKey=1568a23373cb462089c6e310ca9bd7b2&pagesize=100&country=ca"
        getArticlesFromApi(urlString: api_url)
        resetText()
        
        homeBn.setTitleColor(UIColor.lightGray, for: .normal)
        businessBn.setTitleColor(UIColor.white, for: .normal)
        technologyBn.setTitleColor(UIColor.white, for: .normal)
        entertainmentBn.setTitleColor(UIColor.white, for: .normal)
        healthBn.setTitleColor(UIColor.white, for: .normal)
    }
    @IBOutlet weak var homeBn: UIButton!
    @IBAction func businessBnClick(_ sender: Any) {
        api_url = "https://newsapi.org/v2/top-headlines?apiKey=1568a23373cb462089c6e310ca9bd7b2&pagesize=100&country=ca&category=business"
        getArticlesFromApi(urlString: api_url)
        resetText()
        
        homeBn.setTitleColor(UIColor.white, for: .normal)
        businessBn.setTitleColor(UIColor.lightGray, for: .normal)
        technologyBn.setTitleColor(UIColor.white, for: .normal)
        entertainmentBn.setTitleColor(UIColor.white, for: .normal)
        healthBn.setTitleColor(UIColor.white, for: .normal)
    }
    @IBOutlet weak var businessBn: UIButton!
    @IBAction func technologyBnClick(_ sender: Any) {
        api_url = "https://newsapi.org/v2/top-headlines?apiKey=1568a23373cb462089c6e310ca9bd7b2&pagesize=100&country=ca&category=technology"
        getArticlesFromApi(urlString: api_url)
        resetText()
        
        homeBn.setTitleColor(UIColor.white, for: .normal)
        businessBn.setTitleColor(UIColor.white, for: .normal)
        technologyBn.setTitleColor(UIColor.lightGray, for: .normal)
        entertainmentBn.setTitleColor(UIColor.white, for: .normal)
        healthBn.setTitleColor(UIColor.white, for: .normal)
    }
    @IBOutlet weak var technologyBn: UIButton!
    @IBAction func healthBnClick(_ sender: Any) {
        api_url = "https://newsapi.org/v2/top-headlines?apiKey=1568a23373cb462089c6e310ca9bd7b2&pagesize=100&country=ca&category=health"
        getArticlesFromApi(urlString: api_url)
        resetText()
        
        homeBn.setTitleColor(UIColor.lightGray, for: .normal)
        businessBn.setTitleColor(UIColor.white, for: .normal)
        technologyBn.setTitleColor(UIColor.white, for: .normal)
        entertainmentBn.setTitleColor(UIColor.white, for: .normal)
        healthBn.setTitleColor(UIColor.lightGray, for: .normal)
    }
    @IBOutlet weak var healthBn: UIButton!
    @IBAction func entertainmentBnClick(_ sender: Any) {
        api_url = "https://newsapi.org/v2/top-headlines?apiKey=yourKey&pagesize=100&country=ca&category=entertainment"
        getArticlesFromApi(urlString: api_url)
        resetText()
        
        homeBn.setTitleColor(UIColor.white, for: .normal)
        businessBn.setTitleColor(UIColor.white, for: .normal)
        technologyBn.setTitleColor(UIColor.white, for: .normal)
        entertainmentBn.setTitleColor(UIColor.lightGray, for: .normal)
        healthBn.setTitleColor(UIColor.white, for: .normal)
    }
    @IBOutlet weak var entertainmentBn: UIButton!
    
    //MARK: view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? NewsCollectionViewLayout {
            layout.delegate = self
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            columnSwitch.isHidden = false
            columnLabel.isHidden = false
            columnSwitch.addTarget(self, action: #selector(valueChange), for: .valueChanged)
            titleTextSize = 28
        }
        
        networkMonitor.addDelegate(delegate: self)
        
        getArticlesFromApi(urlString: api_url)
        
        homeBn.setTitleColor(UIColor.lightGray, for: .normal)
        if screenWidth < 375 {
            homeBn.titleLabel?.font = .systemFont(ofSize: 12)
            businessBn.titleLabel?.font = .systemFont(ofSize: 12)
            technologyBn.titleLabel?.font = .systemFont(ofSize: 12)
            healthBn.titleLabel?.font = .systemFont(ofSize: 12)
            entertainmentBn.titleLabel?.font = .systemFont(ofSize: 12)
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func valueChange() {
        if columnSwitch.isOn {
            itemsPerRow = 2
        }else {
            itemsPerRow = 1
        }
        
        DispatchQueue.main.async { [weak self] in
            if let layout = self?.collectionView?.collectionViewLayout as? NewsCollectionViewLayout {
                layout.cache.removeAll()
                self?.collectionView.reloadData()
                self?.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true) //scroll to the top
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        networkMonitor.stopMonitoring()
        networkMonitor.removeDelegate(delegate: self)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        guard indexPath.row <= filteredList.count-1 else {
            return cell
        }
        let articleObj = filteredList[indexPath.row]
        
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "news_api")
        let titleLabel = cell.contentView.viewWithTag(2) as! UILabel
        titleLabel.text = articleObj.title
        titleLabel.font = UIFont.systemFont(ofSize: CGFloat(titleTextSize))
        let dateLabel = cell.contentView.viewWithTag(3) as! UILabel
        dateLabel.text = "Published: \(articleObj.publishedAt)"
        titleLabel.sizeToFit()
        
        
        if let imageUrl = articleObj.urlToImage, let url = URL(string: imageUrl){
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data:data)
                        imageView.image = image
                    }
                }
            }
            
            if collectionView.indexPathsForVisibleItems.contains(indexPath) {
                task.priority = URLSessionTask.highPriority
            }else {
                task.priority = URLSessionTask.defaultPriority
            }
            
            task.resume()
        }
        
        return cell
    }
}

extension ViewController: NewsCollectionViewLayoutDelegate {
    func getItemHeight(index: Int) -> CGFloat {
        if index <= filteredList.count - 1 {
            let titleHeight = getLabelHeight(fontSize: titleTextSize, text: filteredList[index].title, numLines: 0)
            let dateHeight = getLabelHeight(fontSize: 17, text: filteredList[index].publishedAt, numLines: 1)
            
            let padding = 10
            
            return screenWidth/CGFloat(itemsPerRow) / 1.7777 + titleHeight + dateHeight + CGFloat(4 * padding)
        }
        return 0
    }
    
    func getNumOfColumns() -> Int {
        return self.itemsPerRow
    }
    
    
    private func getLabelHeight(fontSize: Int, text: String, numLines: Int) -> CGFloat {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: CGFloat(fontSize)) // make sure you set this correctly
        label.text = text
        return label.systemLayoutSizeFitting(CGSize(width: screenWidth/CGFloat(itemsPerRow), height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        if let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let urlString = "\(api_url)&q=\(text)"
            getArticlesFromApi(urlString: urlString)
        }
    }
}

extension ViewController: NetworkMonitorDelegate {
    func statusDidChange(status: NWPath.Status) {
        if status != .satisfied {
            DispatchQueue.main.async{ [weak self] in
                self?.showMsg(msg: "No internet connection")
            }
        }
    }
}


//MARK: private methods
private extension ViewController {
    
    func getArticlesFromApi(urlString: String) {
        
        if !networkMonitor.isConnected {
            DispatchQueue.main.async{ [weak self] in
                self?.showMsg(msg: "No internet connection")
            }
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        self.mediumIndicator.isHidden = false
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        URLCache.shared.removeCachedResponse(for: request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            self.articleObjList.removeAll()
            self.filteredList.removeAll()
            self.sourceNameList.removeAll()
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let apiService = try decoder.decode(APIService.self, from: data)
                    if apiService.totalResults == 0 {
                        DispatchQueue.main.async { [weak self] in
                            self?.mediumIndicator.isHidden = true
                            self?.showMsg(msg: "0 results")
                        }
                        return
                    }
                    
                    let articles = apiService.articles
                    for (index, element) in articles.enumerated() {
                        let articleObj = ArticleObject(from: element)
                        articleObj.id = index
                        
                        self.articleObjList.append(articleObj)
                        
                        if !self.sourceNameList.contains(articleObj.sourceName) {
                            self.sourceNameList.append(articleObj.sourceName)
                        }
                    }
                    
                    self.filteredList = self.articleObjList
                    DispatchQueue.main.async { [weak self] in
                        self?.mediumIndicator.isHidden = true
                        //if let layout = self?.collectionView?.collectionViewLayout as? NewsCollectionViewLayout {
                            //layout.cache.removeAll()
                            self?.collectionView.reloadData()
                            self?.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true) //scroll to the top
                        //}
                    }
                }
                catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.mediumIndicator.isHidden = true
                        self?.showMsg(msg: "Server errors")
                    }
                }
            }else {
                DispatchQueue.main.async { [weak self] in
                    self?.mediumIndicator.isHidden = true
                    if let self = self {
                        if self.networkMonitor.isConnected {
                            self.showMsg(msg: "No response from server")
                        }else {
                            self.showMsg(msg: "No internet connection")
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    private func showMsg(msg: String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func filterAction(sourceName: String) {
        guard !sourceName.isEmpty else {
            return
        }
        
        filteredList.removeAll()
        if (sourceName == "All") {
            filteredList = articleObjList
        }else {
            for articleObj in articleObjList {
                if articleObj.sourceName == sourceName {
                    filteredList.append(articleObj)
                }
            }
        }
        
        let charLimit = 13
        var source = sourceName
        if sourceName.count > charLimit &&  UIDevice.current.userInterfaceIdiom == .phone {
            source = sourceName.prefix(charLimit) + "..."
            self.sourcesBn.title = source
        }else {
            self.sourcesBn.title = "Source: \(source)"
        }
        
        
        self.collectionView.reloadData()
        self.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true) //scroll to the top
    }
    
    private func countrySelected(country: String){
        let substring = api_url.components(separatedBy: "&country=")[1].prefix(2)
        let toBeReplaced = "&country=" + substring
        var urlString = api_url.replacingOccurrences(of: toBeReplaced, with: "")
        
        switch country {
        case "United States":
            urlString += "&country=us"
        case "Great Britan":
            urlString += "&country=gb"
        case "China":
            urlString += "&country=cn"
        case "Hong Kong":
            urlString += "&country=hk"
        case "Taiwan":
            urlString += "&country=tw"
        default:
            urlString += "&country=ca"
        }
        countriesBn.setTitle(country, for: .normal)
        getArticlesFromApi(urlString: urlString)
    }
    
    private func resetText() {
        sourcesBn.title = "Source Filter"
        searchBar.text = ""
        countriesBn.setTitle("Canada", for: .normal)
    }
}
