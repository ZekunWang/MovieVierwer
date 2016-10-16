//
//  Movie.swift
//  MovieViewer
//
//  Created by Zekun Wang on 10/15/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class Movie: NSObject {
    
    var id: Int = 0
    var title = ""
    var overview = ""
    var posterPath: String? = nil
    var releaseDate: Date!
    var originalTitle = ""
    var originalLanguage = ""
    var backdropPath: String? = nil
    var popularity: Double = 0.0
    var voteAverage: Double = 0.0
    var voteCount: Int = 0
    var adult = false
    
    func mapFromMovieDictionary(dictionary: NSDictionary) {
        self.id = dictionary["id"] as! Int
        self.title = dictionary["title"] as! String
        self.overview = dictionary["overview"] as! String
        if let posterPath = dictionary["poster_path"] as? String {
            self.posterPath = posterPath
        }
        self.originalTitle = dictionary["original_title"] as! String
        self.originalLanguage = dictionary["original_language"] as! String
        
        if let backdropPath = dictionary["backdrop_path"] as? String {
            self.backdropPath = backdropPath
        }
        
        self.popularity = dictionary["popularity"] as! Double
        self.voteAverage = dictionary["vote_average"] as! Double
        self.voteCount = dictionary["vote_count"] as! Int
        self.adult = dictionary["adult"] as! Bool
        
        let releaseDateString = dictionary["release_date"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.releaseDate = dateFormatter.date(from: releaseDateString)
    }
    
    class func mapFromMovieArray(dictionaries: [NSDictionary]) -> [Movie] {
        var movies = [Movie]()
        
        for dictionary in dictionaries {
            let movie = Movie()
            movie.mapFromMovieDictionary(dictionary: dictionary)
            movies.append(movie)
        }
        
        return movies
    }

}
