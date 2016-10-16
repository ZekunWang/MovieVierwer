//
//  Person.swift
//  MovieViewer
//
//  Created by Zekun Wang on 10/15/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class Person: NSObject {
    /*
     {
     "id": 283366,
     "cast": [
         {
         "cast_id": 2,
         "character": "Miss Peregrine",
         "credit_id": "542423c50e0a263b810039d8",
         "id": 10912,
         "name": "Eva Green",
         "order": 0,
         "profile_path": "/wqK0BhMuNBvDqIg1bwT9RhYMy6L.jpg"
         },
         {
         "cast_id": 3,
         "character": "Jacob Portman",
         "credit_id": "542423d40e0a263b840039fd",
         "id": 77996,
         "name": "Asa Butterfield",
         "order": 1,
         "profile_path": "/oYtmA3RB4wNhpISRDF4UXLnDQMC.jpg"
         }
     ],
     "crew": [
         {
         "credit_id": "53cfdd9e0e0a265ded0099c3",
         "department": "Directing",
         "id": 510,
         "job": "Director",
         "name": "Tim Burton",
         "profile_path": "/sLjHif5QL1uqDudnHDbnXc6I5G6.jpg"
         },
         {
         "credit_id": "554db1709251413e400018d0",
         "department": "Writing",
         "id": 1465319,
         "job": "Novel",
         "name": "Ransom Riggs",
         "profile_path": null
         }
     ]
     }
     */
    
    // Common
    var id: Int = 0
    var name = ""
    var profilePath = ""
    var creditId = ""
    //    "credit_id": "571e927fc3a36833aa000b3b",
    //    "id": 510,
    //    "name": "Tim Burton",
    //    "profile_path": "/sLjHif5QL1uqDudnHDbnXc6I5G6.jpg"
    
    // Cast
    var character = ""
//    "cast_id": 31,
//    "character": "Pier Cleaner",
//    "order": 36
    
    // Crew
    var job = ""
//    "department": "Directing",
//    "job": "Director",
    
    func mapFromCastDictionary(dictionary: NSDictionary) {
        mapFromCommonDictionary(dictionary: dictionary)
        self.character = dictionary["character"] as! String
    }
    
    func mapFromCrewDictionary(dictionary: NSDictionary) {
        mapFromCommonDictionary(dictionary: dictionary)
        self.job = dictionary["job"] as! String
    }
    
    private func mapFromCommonDictionary(dictionary: NSDictionary) {
        self.id = dictionary["id"] as! Int
        self.name = dictionary["name"] as! String
        self.creditId = dictionary["credit_id"] as! String
        if let profilePath = dictionary["profile_path"] as? String {
            self.profilePath = profilePath
        }
    }
    
    class func mapFromCastArray(dictionaries: [NSDictionary]) -> [Person] {
        var people = [Person]()
        
        for dictionary in dictionaries {
            let person = Person()
            person.mapFromCastDictionary(dictionary: dictionary)
            people.append(person)
        }
        
        return people
    }
    
    class func mapFromCrewArray(dictionaries: [NSDictionary]) -> [Person] {
        var people = [Person]()
        
        for dictionary in dictionaries {
            let person = Person()
            person.mapFromCrewDictionary(dictionary: dictionary)
            people.append(person)
        }
        
        return people
    }
}
