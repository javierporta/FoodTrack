//
//  Meal.swift
//  FoodTracker
//
//  Created by Javier Portaluppi on 08/11/2019.
//  Copyright © 2019 Javier Portaluppi. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject, NSCoding, Codable {
    
    
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    var photoUrl: URL?
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let photoUrl = "photoUrl"
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case photoUrl = "photo"
        case rating
    }
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int, photoUrl: URL?) {
        // Should fail if there’s no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.photoUrl = photoUrl
    }
    
    required convenience init?(coder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else { os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = coder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = coder.decodeInteger(forKey: PropertyKey.rating)
        
        let photoUrl = coder.decodeObject(forKey: PropertyKey.photoUrl) as? URL
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, photoUrl: photoUrl)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(photo, forKey: PropertyKey.photo)
        coder.encode(rating, forKey: PropertyKey.rating)
        coder.encode(photoUrl, forKey: PropertyKey.photoUrl)
    }
    
    
    
}
