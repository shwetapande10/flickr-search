//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import UIKit
import ReactiveSwift

class FlickrSearchViewController: UIViewController {

    //MARK: ui interface objects
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    var searchHandler: UISearchBarDelegate?
    var collectionData: ImageCollectionDataDelegate?
    var collectionScrollHandler: UICollectionViewDelegate?
    
    var flickrSearchInteractor: ImageSearchInteractor?
    var flickrDataPresenter: ImagePresenter?
    var flickrApiService: ImageSearchService?
    
    private var disposeObserver: Disposable?
    
    //MARK: init
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    fileprivate func setUp() {
        self.instantiateDependencies()
        self.setDependencies(presenter: flickrDataPresenter!, interactor : flickrSearchInteractor!, service: flickrApiService!)
        self.addModelChangeObserver()
    }
    
    //MARK: Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackLabelToImageCollection()
        addRefreshControl()
        if #available(iOS 11.0, *) {
            imageCollectionView?.contentInsetAdjustmentBehavior = .always
        }
        else{
            self.automaticallyAdjustsScrollViewInsets = true
        }
        assignDependencies()
    }
    
    //MARK: Dependency Injection
    
    fileprivate func instantiateDependencies(){
        let imageData = ImageData(pageData: PageMetaData(currentPageNo: 1, totalPages: 1))
        let flickrpresenter = FlickrSearchPresenter(model: imageData)
        let flickrservice = FlickrAPIService()
        let flickrinteractor = FlickrSearchInteractor(presenter: flickrpresenter, service: flickrservice)
        setDependencies(presenter: flickrpresenter, interactor: flickrinteractor, service: flickrservice)
    }
    
    func setDependencies(presenter: ImagePresenter, interactor: ImageSearchInteractor,service: ImageSearchService){
        flickrDataPresenter = presenter
        flickrSearchInteractor = interactor
        flickrApiService = service
        searchHandler = FlickrSearchHandler(withInteractor: flickrSearchInteractor!)
        collectionData = FlickrCollectionDataHandler(withInteractor: flickrSearchInteractor!)
    }
    
    fileprivate func assignDependencies() {
        searchBar.delegate = searchHandler
        imageCollectionView.dataSource = collectionData
        collectionScrollHandler = FlickrCollectionScrollHandler(withInteractor: flickrSearchInteractor!, andSearchBar: self.searchBar)
        imageCollectionView.delegate = collectionScrollHandler
        searchBar.becomeFirstResponder()
    }

    //MARK: View manipulation methods
    
    fileprivate func addModelChangeObserver(){
        let dataChangeObserver =
            Signal<ResponseStatus, NoError>.Observer(value: { [weak self] value in
                DispatchQueue.main.async {
                    self?.reloadView(value)
                }
            })
        disposeObserver = flickrDataPresenter!.pipeTuple!.0.observe(dataChangeObserver)
    }
    
    func reloadView(_ respStatus:ResponseStatus){
        if(respStatus != ResponseStatus.pending){
            (collectionScrollHandler as! FlickrCollectionScrollHandler).resetFetching()
        }
        imageCollectionView.refreshControl?.endRefreshing()
        let collectionData = self.collectionData as! FlickrCollectionDataHandler
        collectionData.reloadImages(imageCollectionView)
        UIApplication.shared.isNetworkActivityIndicatorVisible = respStatus == ResponseStatus.pending
    }
    
    //MARK: View utility
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
     func addBackLabelToImageCollection() {
        let backgroundLabel: UILabel = UILabel(frame: CGRect(x:0, y:0, width:imageCollectionView.bounds.size.width, height:imageCollectionView.bounds.size.height))
        backgroundLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
        backgroundLabel.textAlignment = .center
        backgroundLabel.numberOfLines = 2
        imageCollectionView.backgroundView = backgroundLabel
        setBackgroundLabel(Constants.Labels.InitialSearchHint)
    }
    
     func setBackgroundLabel(_ labelString: String) {
        let backgroundLabel = imageCollectionView.backgroundView as? UILabel
        backgroundLabel?.text = labelString
    }
    
     func addRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        self.imageCollectionView.refreshControl = refreshControl
    }
    
    @objc func refreshControlAction(){
            guard let searchStr = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchStr.isEmpty else {
                self.imageCollectionView.refreshControl?.endRefreshing()
                return
            }
            self.flickrSearchInteractor!.searchImages(searchString: searchStr, requestStatus: RequestStatus.refresh)
    }
    
    //MARK: destroy
    deinit {
        disposeObserver?.dispose()
    }
    
}
