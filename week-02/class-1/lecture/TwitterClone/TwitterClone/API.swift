//
//  API.swift
//  TwitterClone
//
//  Created by Ryan David on 2/9/16.
//  Copyright © 2016 Michael Babiy. All rights reserved.
//

import Foundation
import Accounts
import Social

class API
{
    static let shared = API()
    private init() {}
    
    var account: ACAccount?
    
    func GETTweets(completion: (tweets: [Tweet]?) -> ()) // check out and timeline. pass into timeline update passline to here.  checks if logged in if not else.
    {
        if let _ = self.account {
            
            self.updateTimeline(completion)
            
        } else {
            
            self.login({ (account) -> () in
                
                if let account = account {
                    
                    //Set the account.
                    API.shared.account = account
                    
                    //Make tweets call
                    self.updateTimeline(completion)
                    
                }else { print("Account is nil.") }
                
            })
            
        }
    }
    
    private func updateTimeline(completion: (tweets: [Tweet]?) -> ()) // if we have self.timeline we are passing this insot that.
    {
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json"), parameters: nil)
        
        request.account = self.account
        request.performRequestWithHandler { (data, response, error) -> Void in //not making any guarantee. make sure its on main thread
            
            if let _ = error {
                print("ERROR: SLRequest type .GET could not be completed.")
                NSOperationQueue.mainQueue().addOperationWithBlock{ completion(tweets: nil) }; return
                
            }
            
            switch response.statusCode {
                
            case 200...299:
                
                JSONParser.tweetJSONFrom(data, completion: { (success, tweets) -> () in
                    completion(tweets: tweets) //$1
                })
                
            default:
                print("ERROR: SLRequest type .GET returned status code \(response.statusCode)")
                NSOperationQueue.mainQueue().addOperationWithBlock{ completion(tweets: nil) };
                
            }
        }
    }
    private func login(completion: (account: ACAccount?) -> ()) // dont want someone to call updatetimeline or login directly.
    {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in //will come back in separate queue
            if let _ = error {
                print("ERROR: Request access to accounts returned an error.")
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(account: nil);
                }); return
                
            }
            if granted {
                if let account = accountStore.accountsWithAccountType(accountType).first as? ACAccount { //returns an array hint hint for multiple accounts?
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completion(account: account);
                    }); return
                }
                print("Error: No twitter account were found on this device.")
                NSOperationQueue.mainQueue().addOperationWithBlock{ completion(account: nil)
                    
                }; return
            }
            print("Error: This app requires access to Twitter Accounts.")
            NSOperationQueue.mainQueue().addOperationWithBlock{ completion(account: nil)
            }; return
        }
    }
    
    func GETOAuthUser(completion: (user: User?) -> ())
    {
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json"), parameters: nil)
        
        request.account = self.account
        request.performRequestWithHandler { (data, response, error) -> Void in
            
            if let _ = error {
                print("ERROR: SLRequest type .GET returned status code \(response.statusCode)")
                NSOperationQueue.mainQueue().addOperationWithBlock{ completion(user: nil) }; return
                
            }
            switch response.statusCode {
            case 200...299:
                do {
                    if let userJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject] {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(user: JSONParser.userFromTweetJSON(userJSON))
                        })
                    }
                } catch _ {}
            case 300...399:
                print("Error [USER]: SLRequest type .GET returned status code \(response.statusCode)")
                NSOperationQueue.mainQueue().addOperationWithBlock{ completion(user: nil) }
                
            default:
                print("Error [USER]: SLRequest type .GET returned status code \(response.statusCode)")
                NSOperationQueue.mainQueue().addOperationWithBlock{ completion(user: nil) }
            }
        }
}
}