//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Timothy Mak on 2/2/17.
//  Copyright © 2017 Timothy Mak. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    var photoURLString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let photoURL = URL(string: photoURLString)
        photoView.setImageWith(photoURL!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
