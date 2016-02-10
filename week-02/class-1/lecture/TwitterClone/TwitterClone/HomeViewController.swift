//
//  ViewController.swift
//  TwitterClone
//
//  Created by Michael Babiy on 2/8/16.
//  Copyright © 2016 Michael Babiy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource //creating New class named HomeViewController. it is inheriting from UIViewController and conforming to UITableVIewDataSources protocol
{
    
    @IBOutlet weak var tableView: UITableView! //connecting the view with the code subclass of UIView
    
    var datasource = [Tweet]() { // array of Tweet classes based on JSON files.
        didSet {
            self.tableView.reloadData() // this function reloads tableview each time something is changed on the array.
        }
    }
    
    override func viewDidLoad() // original code. override will help intit
    {
        super.viewDidLoad()
        self.setupTableView()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated) // informing the view to animate
        self.update()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning() //original code
    }
    
    func setupTableView()
    {
        self.tableView.dataSource = self //setting the data source of the visual aid to the class HomeViewController. this allows view to update with any variables listed in this class
    }
    
    func update()
    {
        API.shared.GETTweets { (tweets) -> () in // will get tweets
            if let tweets = tweets {
                    self.datasource = tweets
            }
            API.shared.GETOAuthUser{ (user) -> () in
                if let user = user {
                    print(user.name)
                    print(user.profileImageUrl)
                    print(user.location)
                }
            }
        }
    }
}
    extension HomeViewController
    {
        func configureCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell // Function for conveyorbelting the table
        {
            let tweetCell = self.tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) //grabs the tweetcell that has been dequeued by user(dequque means no longer visible)
            let tweet = self.datasource[indexPath.row] //grabs the specific tweet from array datasource
            tweetCell.textLabel?.text = tweet.text // sets the dequeue cells text equal to the tweets text.
            
            // Return cell.
            return tweetCell // returns the dequeued cell
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int // NECESSARY TO CONFROM TO UITableViewDataSource
        {
            return self.datasource.count //returns maxiumum of rows at any given time
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell //NECESSARY TO CONFORM to UITableViewDataSource
        {
            return self.configureCellForIndexPath(indexPath) //returns the reused cell from configureCellForIndexPath and adds it to table.
        }
}

