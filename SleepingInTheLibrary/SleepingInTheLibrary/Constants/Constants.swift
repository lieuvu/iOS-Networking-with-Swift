//
//  Constants.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

// MARK: - Constants

enum Constants {
    
    // MARK: Flickr
    // **********************************************************************
    
    enum Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }

    // MARK: Flickr Parameter Keys
    // **********************************************************************
    
    enum FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    // MARK: Flickr Parameter Values
    // **********************************************************************
    
    enum FlickrParameterValues {
        static let APIKey = "2d79a5a498f94c03f5a499d04b105c2f"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Keys
    // **********************************************************************
    
    enum FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    // **********************************************************************
    
    enum FlickrResponseValues {
        static let OKStatus = "ok"
    }
}
