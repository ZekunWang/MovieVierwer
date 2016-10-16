//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zekun Wang on 9/25/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    static let VIEW_KEY = "view_key"
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var viewSwitchBarButton: UIBarButtonItem!
    @IBOutlet var errorImageView: UIImageView!
    
    let backgroundView = UIView()
    
    var rawMovies: [Movie]?
    var movies: [Movie]?
    var endpoint: String = ""
    var isList: Bool = true
    
    var tableRefreshControl: UIRefreshControl!
    var collectionRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorImageView.tintColor = UIColor.white
        viewSwitchBarButton.tintColor = UIColor.blue
        
        backgroundView.backgroundColor = UIColor.lightGray
        
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Clear keyboard when scroll
        tableView.keyboardDismissMode = .onDrag
        collectionView.keyboardDismissMode = .onDrag
        
        searchBar.delegate = self
        
        errorView.alpha = 0
        collectionView.alpha = 0
        
        let defaults = UserDefaults.standard
        isList = defaults.bool(forKey: MoviesViewController.VIEW_KEY)
        
        showViews(duration: 0)
        
        // Initialize a UIRefreshControl
        tableRefreshControl = UIRefreshControl()
        collectionRefreshControl = UIRefreshControl()
        tableRefreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        collectionRefreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        tableView.insertSubview(tableRefreshControl, at: 0)
        collectionView.insertSubview(collectionRefreshControl, at: 0)
        
        // UICollectionViewFlowLayout
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let screenWidth = UIScreen.main.bounds.width;
        flowLayout.itemSize = CGSize(width: screenWidth/2 - 15, height: 284);
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        self.collectionView.collectionViewLayout = flowLayout
        
        refreshData()
    }
    
    func refreshData() {
        // now_playing API Call
        let url = URL(string:AppConstants.baseUrl + "\(endpoint)?api_key=\(AppConstants.apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
            
            // Tell the refreshControl to stop spinning
            self.tableRefreshControl.endRefreshing()
            self.collectionRefreshControl.endRefreshing()
            
            // Display HUD right before the request is made
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            if errorOrNil != nil {
                print("request error")
                self.errorView.alpha = 1
                
                UIView.animate(withDuration: 1.8, animations: {
                    self.errorView.alpha = 0
                })

            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    
                        let rawMoviesDictionaries = responseDictionary["results"] as? [NSDictionary]
                        self.rawMovies = Movie.mapFromMovieArray(dictionaries: rawMoviesDictionaries!)
                        self.filterData(searchText: "")
                        // Reload the data now that there is new data
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                    }
                }
            }
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
        });
        
        task.resume()
    }
    
    func filterData(searchText:String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            movies = rawMovies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            movies = rawMovies?.filter({(rawMovieItem: Movie) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (rawMovieItem.title).range(of: searchText, options: .caseInsensitive) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
        collectionView.reloadData()

    }
    
    @IBAction func onViewSwitched(_ sender: AnyObject) {
        isList = !isList
        showViews(duration: 0.4)
        saveData()
    }
    
    func showViews(duration: Double) {
        collectionView.alpha = 0
        tableView.alpha = 0
        
        let list_icon = UIImage(named: "list_icon")
        let grid_icon = UIImage(named: "grid_icon")
        
        viewSwitchBarButton.image = isList ? list_icon : grid_icon
        
        if (isList) {
            UIView.animate(withDuration: duration, animations: {
                self.tableView.alpha = 1
            })
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.alpha = 1
            })
        }
    }
    
    func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(isList, forKey: MoviesViewController.VIEW_KEY)
        defaults.synchronize()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData(searchText: searchText)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCount();
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount()
    }
    
    func getCount() -> Int {
        if movies != nil {
            return movies!.count
        } else {
            return 0
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as!  MovieCell
        
        print("table view will select")
        cell.backgroundView = self.backgroundView
        return indexPath
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as!  MovieCell
        print("table view did selected")
        cell.backgroundView = nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        print("table view: " + String(indexPath.row))
        let movie = movies![indexPath.row]
        
        cell.movie = movie
        
        cell.selectedBackgroundView = backgroundView
        
        print("row \(indexPath.row)")

//        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
//        cell.titleLabel.text = "hello"
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as!  MovieCollectionViewCell
        print("collection view will select")
        cell.backgroundView = self.backgroundView
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as!  MovieCollectionViewCell
        
        print("collection view did selected")
        cell.backgroundView = nil
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        print("collection view: " + String(indexPath.row))
        let movie = movies![indexPath.row]
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        if let posterPath = movie.posterPath {
            let posterURL = URL(string: baseUrl + posterPath)
            let posterURLRequest = URLRequest(url: posterURL!)
            cell.posterImageView.setImageWith(posterURLRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterImageView.alpha = 0
                    cell.posterImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        cell.posterImageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterImageView.image = image
                }
                }, failure: nil)
        }
        
        cell.titleLabel.text = movie.title
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var indexPath: IndexPath!
        if (isList) {
            let cell = sender as! UITableViewCell
            indexPath = tableView.indexPath(for: cell)!
        } else {
            let cell = sender as! UICollectionViewCell
            indexPath = collectionView.indexPath(for: cell)!
        }
        let movie = movies![indexPath.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
