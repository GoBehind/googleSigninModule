//
//  DetailViewController.swift
//  MyGDrive
//
//  Created by 王冠之 on 2020/5/11.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMSessionFetcher
import GoogleSignIn

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var resultImageView: UIImageView!
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let file = detailItem, let imageView = resultImageView else {
            return
        }
        guard let identifier = file.identifier else {
            assertionFailure("Fail to get File ID")
            return
        }
        
        GDriveManager.shared.downloadFile(identifier: identifier) { (data, error) in
            if let error = error {
                print("Download fail: \(error)")
                return
            }
            guard let data = data else {
                assertionFailure("Invalid data")
                return
            }
            imageView.image = UIImage(data: data)
        }
        
//        let urlString = String(format: "https://www.googleapis.com/drive/v2/files/\(identifier)?alt=media")
//        let dirve = GTLRDriveService()
//
//        dirve.authorizer = GIDSignIn.sharedInstance()?.currentUser.authentication.fetcherAuthorizer()
//
//        let fetcher = dirve.fetcherService.fetcher(withURLString: urlString)
//
//        fetcher.beginFetch { (data, error) in
//            if let error = error {
//                print("Download fail: \(error)")
//                return
//            }
//            guard let data = data else {
//                assertionFailure("Invalid data")
//                return
//            }
//            imageView.image = UIImage(data: data)
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }
    
    var detailItem: GTLRDrive_File? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

//Set: 設定一個property的值
//Get: 取得一個property的值

struct Tall {
    var 身高公分 = 0.0
    
    var 身高英吋: Double {
        set {
            身高公分 = newValue * 2.54
        }
        get {
            return 身高公分 / 2.54
        }
    }
}
