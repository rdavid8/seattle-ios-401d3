//
//  JSONParser.swift
//  TwitterClone
//
//  Created by Michael Babiy on 2/8/16.
//  Copyright © 2016 Michael Babiy. All rights reserved.
//

import UIKit

typealias JSONParserCompletion = (success: Bool, tweets: [Tweet]?) -> () //creates a typealias for a tuple whose key value pairs are boolean and an optional array of classes of Tweet and returns  or a initializer??

class JSONParser
{
    
    class func tweetJSONFrom(data: NSData, completion: JSONParserCompletion) //class func for parsing the JSON
    {
        //        let serializationQ = dispatch_queue_create("serializationQ", nil)
        //
        //        dispatch_async(serializationQ) { () -> Void in
        //            //do your business here..
        //
        //            dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //                // call completion here
        //            })
        
        NSOperationQueue().addOperationWithBlock({ () -> Void in
            
            
            do { // error handling
                if let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String : AnyObject]] {
                    // rootObject is trying to serialize the JSON with with an option of that allows the dictionaries or arrays to be mutable and checks if that is in the form of an array of dictionaries. if not, it goes to catch below.
                    var tweets = [Tweet]() //creating a variable tweets assigning it to array of class  Tweet
                    
                    for tweetJSON in rootObject { //for loop of the array of Dictionaries. tweetJSON is each dictionary in the array
                        if let
                            text = tweetJSON["text"] as? String, //pulled data from JSON and assign to constants
                            id = tweetJSON["id_str"] as? String,
                            userJSON = tweetJSON["user"] as? [String : AnyObject] {
                                //the if let statement is checking if the key value pairs are returning the correct value type for the current tweet.
                                let user = self.userFromTweetJSON(userJSON) // if all is true pass the user Dictionary into the helper function
                                let tweet = Tweet(text: text, id: id, user: user) // plug in all the data collected into a Tweet class
                                
                                tweets.append(tweet) // add that class to the array created earlier
                        }
                    }
                    
                    // Completion
                    //                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in will not run in mainqueue since commented out
                    completion(success: true, tweets: tweets) //this is a function because of typealias initializer
                }
                // above is when the JSON succeeds in grabbing data. below is when it fails
            } catch _{ completion(success: false, tweets: nil) }
        })
    }
        // MARK: Helper Functions
        
        class func userFromTweetJSON(tweetJSON: [String : AnyObject]) -> User //HELPER FUNCTION checks if users data exist
        {
            guard let name = tweetJSON["name"] as? String else { fatalError("Failed to parse the name. Soething is worng with JSON.") }
            guard let  profileImageUrl = tweetJSON["profile_image_url"] as? String else { fatalError("Failed to parse the profile image url. Soething is worng with JSON.") }
            guard let location = tweetJSON["location"] as? String else { fatalError("Failed to parse the location. Soething is worng with JSON.") }
            
            return User(name: name, profileImageUrl: profileImageUrl, location: location) //sends back user class with correct data
        }
        
        
        // MARK: First day, load JSON from bundle.
        
        class func JSONData() -> NSData
        {
            guard let tweetJSONPath = NSBundle.mainBundle().URLForResource("tweet", withExtension: "json") else { fatalError("Missing tweet.json file.") } // if path is not found fatal error.
            guard let tweetJSONData = NSData(contentsOfURL: tweetJSONPath) else { fatalError("Error creating NSData object.") } //if NSData can not create the object results in fatal
            return tweetJSONData // NSData created the object successfully returned the whole thing.
        }
    }