//
//  MainViewController.swift
//  Test
//
//  Created by Patrick Ngo on 28/3/17.
//  Copyright © 2017 ngo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UITableViewController
{
    var fullRefreshing = false
    var page = 1                    //current page number
    var movieData: [JSON]? = []    //data list received from network
    
    var allowLoadMoreAtBottom = true
    var bottomLoading = false
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //attach refresh control
        enableRefreshControl()
        
        //load initial data
        loadData()
    }

    @IBAction func orderBy(_ sender: Any)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let orderByDateButton = UIAlertAction(title: "Order by name", style: .default, handler:
        { (action) -> Void in
            
            self.movieData?.sort(by: { $0["name"].stringValue < $1["name"].stringValue})
            self.tableView.reloadData()
                
        })
        
        let  orderByPopularityButton = UIAlertAction(title: "Order by popularity", style: .default, handler:
            { (action) -> Void in
                            
            self.movieData?.sort(by: { $0["popularity"].doubleValue > $1["popularity"].doubleValue } )
            self.tableView.reloadData()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler:
        { (action) -> Void in
            
        })
        
        
        alertController.addAction(orderByDateButton)
        alertController.addAction(orderByPopularityButton)
        alertController.addAction(cancelButton)
        
        navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func enableRefreshControl()
    {
        if(refreshControl != nil)
        {
            return
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.tintColor = UIColor.white
        self.refreshControl!.addTarget(self, action: #selector(MainViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    
    func refresh(sender:AnyObject)
    {
        fullRefreshing = true
        page = 1               //reset page to 1

        loadData()
    }
    
    
    fileprivate func loadData()
    {
        
        API.callMethod(method: "person/popular", parameters: ["page":String(self.page)], completionHandler:
            {   (result) -> () in
                
                if(result != nil)
                {
                    
                    let movies = JSON(result as Any)
                    
                    
                    if self.fullRefreshing
                    {
                        self.movieData?.removeAll() //remove all elements when full refresh
                        self.fullRefreshing = false
                    }
                    
                    //set data
                    if let movieResults = movies["results"].array {
                        self.movieData?.append(contentsOf: movieResults)
                    }
                    
                    //stop refresh animation
                    self.refreshControl?.endRefreshing()
                    
                    
                    self.bottomLoading = false
                    
                    //refresh data
                    self.tableView.reloadData()
                    
                }
        })
    }
    
    
    
    
    
    
    
    
    // MARK: - ScrollView delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if(!allowLoadMoreAtBottom)
        {
            return
        }
        
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if (!bottomLoading && scrollOffset + scrollViewHeight > scrollContentSizeHeight - 100) {
            //We have scrolled near to the end, load the next page
            
            //add a page
            bottomLoading = true
            page += 1
            tableView.reloadData()
            
            loadData()

        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        var bottomLoading = 0
        if(self.bottomLoading) {
            bottomLoading = 1
        }
        
        return 1+bottomLoading
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //regular section
        if section == 0
        {
            if let movieData = self.movieData
            {
                return movieData.count
            }
            else
            {
                return 0
            }
        }
        //loading section
        else
        {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //regular cells
        if indexPath.section == 0
        {
            //get the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TableViewCell

            //get the entry info
            let jsonData = movieData![indexPath.row].dictionaryValue
            
            // Configure the cell...
            cell.populateData(data: jsonData)

            return cell
        }
            
        //Loading cell
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            cell.startAnimating()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //loading cell
        if indexPath.section == 1
        {
            return 50
        }
        //actor cell
        else
        {
            return 217
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //segue to DetailView
        performSegue(withIdentifier: "DetailView", sender: self)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        let selectedActor = movieData?[self.tableView.indexPathForSelectedRow!.row].dictionary
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Create an instance of PlayerTableViewController and pass the variable
        let destinationVC = segue.destination as! DetailViewController
        destinationVC.actorData = selectedActor
    }
 

}
