//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Timothy Mak on 1/31/17.
//  Copyright © 2017 Timothy Mak. All rights reserved.
//

import UIKit
import AFNetworking

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [NSDictionary] = []
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var currentOffset = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // Add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        loadingMoreView?.center = self.view.center
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 240;
        
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        // This is where you will store the returned array of posts in your posts property
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.reloadData() 
                    }
                }
        });
        task.resume()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let post = posts[indexPath.row]
        
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary]{
            let imageURLString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageURL = URL(string: imageURLString!){
                cell.photoImageView.setImageWith(imageURL)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl){
        
        // ... Create the NSURLRequest (myRequest) ...
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let myRequest = URLRequest(url: url!)
        
        //Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: myRequest as URLRequest, completionHandler: { (data, response, error) in
            
            if let responseData = data {
                // ... Use the new data to update the data source ...
                if let responseDictionary = try! JSONSerialization.jsonObject(                                                                                with: responseData, options:[]) as? NSDictionary {
                    
                    // Add the loaded movies to the movies array
                    if let responseDictionary = responseDictionary["results"] as? [NSDictionary] {
                        self.posts = responseDictionary
                    }
                }
            }
            
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    func loadMoreData(){
        
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(currentOffset)")
        let myRequest = URLRequest(url: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue: OperationQueue.main)
        
        let task : URLSessionDataTask = session.dataTask(with: myRequest as URLRequest, completionHandler: { (data, response, error) in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
            self.currentOffset += 20
            // ... Use the new data to update the data source ...
            if let responseData = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(                                                                                with: responseData, options:[]) as? NSDictionary {

                    // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                    // This is how we get the 'response' field
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    
                    // This is where you will store the returned array of posts in your posts property
                    self.posts.append(contentsOf: responseFieldDictionary["posts"] as! [NSDictionary])
                    // Reload the tableView now that there is new data
                    self.tableView.reloadData()
                }
            }
            
        });
        task.resume()
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading){
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let vc = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        
        let post = posts[(indexPath?.row)!]
        let photos = post.value(forKeyPath: "photos") as? [NSDictionary]
        vc.photoURLString = photos?[0].value(forKeyPath: "original_size.url") as! String!
        
        /*
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary]{
            if let photoURL = photos[(indexPath?.row)!].value(forKeyPath: "original_size_url") as? String{
                vc.photoURLString = photoURL
            }
        }*/
        
    }
}
