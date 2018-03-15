//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import SVProgressHUD

class ViewController: UIViewController {

    // MARK: Outlets
    // **********************************************************************
    
    /// The phot image view.
    @IBOutlet weak var photoImageView: UIImageView!
    
    /// The photo title label.
    @IBOutlet weak var photoTitleLabel: UILabel!
    
    /// The grab image button.
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    // **********************************************************************
    
    /// Press button grab new image.
    ///
    /// - Parameters:
    ///     - sender: The grab new image button.
    @IBAction func grabNewImage(_ sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    // **********************************************************************
    
    private func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    // **********************************************************************
    
    /// Get image from Flickr.
    private func getImageFromFlickr() {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                SVProgressHUD.showError(withStatus: "Error!")
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            // GUARD: Did we get a sucessfull 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a satus code other than 2XX")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!

            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data JSON: '\(data)'")
                return
            }
            
            // GUARD: Did Flickr return an error(stat != ok)?
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an erro. See error code and message in \(parsedResult)")
                return
            }
            
            // GUARD: Are the "photos" and "photo" keys in our result?
            guard
                let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject],
                let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
            else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)'")
                return
            }
            
        
            // select a random photo
            let randomPhotoIndex: Int = numericCast(arc4random_uniform(numericCast(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            // GUARD: Does our phot have a key for "url_m"
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in '\(photoDictionary)'")
                return
            }
            
            // if an image exists at the url, set the image and title
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    self.photoImageView.image = UIImage(data: imageData)
                    self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                    self.setUIEnabled(true)
                    SVProgressHUD.dismiss()
                }
            } else {
                displayError("Image does not exist at \(String(describing: imageURL))")
            }
            
        }
        
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: photoImageView.frame.size.height/2))
        SVProgressHUD.setBackgroundColor(UIColor.darkGray)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setMaximumDismissTimeInterval(1.0)
        SVProgressHUD.show()
        task.resume()
    }
    
    /// Form the request string from the paramters to have ASCII character safe.
    ///
    /// - Parameters:
    ///     - parameters: The parameters to include in the request.
    ///
    /// - Returns: The request string.
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs: [String] = []
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapeValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + escapeValue!)
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
