//
//  MainViewController.swift
//  Test
//
//  Created by Netccentric on 28/3/17.
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        //attach refresh control
        enableRefreshControl()
        
        //load initial data
        loadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableRefreshControl()
    {
        if(self.refreshControl != nil)
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
        self.fullRefreshing = true
        self.page = 1               //reset page to 1

        self.loadData()
    }
    
    
    func loadData()
    {
        API.callMethod(method: "actors", parameters: ["page":String(self.page)], completionHandler:
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
                    self.movieData?.append(contentsOf: movies["data"].arrayValue)
                    
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
        if(!self.allowLoadMoreAtBottom)
        {
            return
        }
        
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height-100
        let scrollOffset = scrollView.contentOffset.y
        
        if (!self.bottomLoading && scrollOffset + scrollViewHeight > scrollContentSizeHeight) {
            //We have scrolled near to the end, load the next page
            
            //add a page
            self.bottomLoading = true
            self.page += 1
            self.tableView.reloadData()
            
            self.loadData()

        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        
        
        var bottomLoading = 0
        if(self.bottomLoading) {
            bottomLoading = 1
        }
        
        return 1+bottomLoading
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        
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
        if indexPath.section == 1
        {
            return 50
        }
        else
        {
            return 217
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
