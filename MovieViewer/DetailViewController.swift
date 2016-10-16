//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Zekun Wang on 9/25/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var overviewView: UIView!
    @IBOutlet var castView: UIView!
    @IBOutlet var crewView: UIView!
    @IBOutlet var trailerView: UIView!
    @IBOutlet var playerView: YTPlayerView!
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var voteAverageLabel: UILabel!
    
    @IBOutlet var castCollectionView: UICollectionView!
    @IBOutlet var crewCollectionView: UICollectionView!
    
    var movie: Movie!
    var cast: [Person]?
    var crew: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uer vague poster image
        if let posterPath = movie.posterPath {
            let posterURL = URL(string: AppConstants.imageUrlW45 + posterPath)
            posterImageView.setImageWith(posterURL!)
        }
        
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
        crewCollectionView.dataSource = self
        crewCollectionView.delegate = self
        
        let viewBackgroudColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
        let transparentBackgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        infoView.backgroundColor = viewBackgroudColor
        overviewView.backgroundColor = viewBackgroudColor
        castView.backgroundColor = viewBackgroudColor
        crewView.backgroundColor = viewBackgroudColor
        trailerView.backgroundColor = viewBackgroudColor
        castCollectionView.backgroundColor = transparentBackgroundColor
        crewCollectionView.backgroundColor = transparentBackgroundColor
        
        if let packdropPath = movie.backdropPath {
            let posterURL = URL(string: AppConstants.imageUrlW342 + packdropPath)
            backdropImageView.setImageWith(posterURL!)
        }
        
        titleLabel.text = movie.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
        voteCountLabel.text = String(movie.voteCount)
        voteAverageLabel.text = String(movie.voteAverage)
        overviewLabel.text = movie.overview
        overviewLabel.sizeToFit()
        
        // UICollectionViewFlowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let screenWidth = UIScreen.main.bounds.width;
        flowLayout.itemSize = CGSize(width: screenWidth/3, height: 138);
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        
        let flowLayout1 = UICollectionViewFlowLayout()
        flowLayout1.scrollDirection = .horizontal
        flowLayout1.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        flowLayout1.itemSize = CGSize(width: screenWidth/3, height: 138);
        flowLayout1.minimumInteritemSpacing = 0
        flowLayout1.minimumLineSpacing = 10
        
        self.castCollectionView.collectionViewLayout = flowLayout
        self.crewCollectionView.collectionViewLayout = flowLayout1
        
        loadCastAndCrew()
        loadVideo()
        
        // Switch to clear poster image
        if let posterPath = movie.posterPath {
            let clearPosterURL = URL(string: AppConstants.imageUrlW500 + posterPath)
            posterImageView.setImageWith(clearPosterURL!)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func loadCastAndCrew() {
        // credits API Call
        // https://api.themoviedb.org/3/movie/283366/credits?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed
        let url = URL(string: AppConstants.baseUrl + "\(movie.id)/credits?api_key=\(AppConstants.apiKey)")
        print("cast and crew : \(url)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
            
            if errorOrNil != nil {
                print("request error")
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                        print("video data: \(responseDictionary)")
                        let rawCastDictionaries = responseDictionary["cast"] as? [NSDictionary]
                        let rawCrewDictionaries = responseDictionary["crew"] as? [NSDictionary]
                        
                        self.cast = Person.mapFromCastArray(dictionaries: rawCastDictionaries!)
                        self.castCollectionView.reloadData()
                        self.crew = Person.mapFromCrewArray(dictionaries: rawCrewDictionaries!)
                        self.crewCollectionView.reloadData()
                        
                        print("cast: \(rawCastDictionaries)")
                        print("crew: \(rawCrewDictionaries)")
                    }
                }
            }
        });
        
        task.resume()
    }

    func loadVideo() {
        // video API Call
        // https://api.themoviedb.org/3/movie/283366/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed
        let url = URL(string: AppConstants.baseUrl + "\(movie.id)/videos?api_key=\(AppConstants.apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
            
            if errorOrNil != nil {
                print("request error")
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                        print("video data: \(responseDictionary)")
                        let rawVideos = responseDictionary["results"] as? [NSDictionary]
                        if rawVideos?.count == 0 {
                            return
                        }
                        let videoKey = rawVideos?[0]["key"] as? String
                        print("video key: \(videoKey!)")
                        self.playerView.load(withVideoId: videoKey!)
                    }
                }
            }
        });
        
        task.resume()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == castCollectionView {
            return cast != nil ? cast!.count : 0
        } else {
            return crew != nil ? crew!.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell row: \(indexPath.row)")
        let isCrew = collectionView != castCollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCollectionViewCell", for: indexPath) as! PersonCollectionViewCell
        let person = isCrew ? crew?[indexPath.row] : cast?[indexPath.row]
        
        cell.isCrew = isCrew
        cell.person = person
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
