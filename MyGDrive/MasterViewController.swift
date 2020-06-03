//
//  MasterViewController.swift
//  MyGDrive
//
//  Created by 王冠之 on 2020/5/11.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

let clientID = "467691473846-4flvj1h2a5iv2q7odttv86qn5ipu8ib4.apps.googleusercontent.com"

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [GTLRDrive_File]()
    //MARK:- homework1
    let signinmanager = GSigninManager()
    
    var authorizer: GTMFetcherAuthorizationProtocol?
    let manager = GDriveManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- homework1
        signinmanager.delegate = self
        
        navigationItem.leftBarButtonItem = editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    //MARK:-homework2
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signinmanager.prepareSigninAndDidApper(clientID: clientID, viewController: self) { (success, authorizer) in
            if success{
                self.manager.setAuthorizer(authorizer: authorizer!)
                self.downloadFilelist()
            }
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
        
        //Prepare file to be upload.
        guard let fileURL = Bundle.main.url(forResource: "1095.jpg", withExtension: nil) else {
            assertionFailure("Fail to get url of bundled file")
            return
        }
        manager.uploadFile(url: fileURL,
                           mimeType: "image/jpeg",
                           name: "MyClass_\(Date())",
                           description: "File of My Class")
        {
            (success, error) in
            if success {
                self.downloadFilelist()
            }
        }
    }
    //MARK:- 取得檔案清單
    func downloadFilelist(){
        manager.delegate = self
        manager.downloadFilelist2()
    }
    // MARK:- Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = objects[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }
    // MARK:- Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = objects[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let identifier = objects[indexPath.row].identifier else {
                assertionFailure("Fail to get File ID")
                return
            }
            
            manager.deleteFile(identifier: identifier) { (success, error) in
                if success {
                    self.downloadFilelist()
                }
            }
        } else if editingStyle == .insert {
            //...
        }
    }
}

extension MasterViewController: GDriveFileListDelegate{
    func didUpdate(manager: GDriveManager, files: [GTLRDrive_File]?, error: Error?) {
        if let error = error{
            print("Download Fail: \(error)")
            return
        } else if let files = files{
            self.objects = files
            print("Total: \(files.count)")
            self.tableView.reloadData()
        }
    }
}
//MARK:- homework3
extension MasterViewController: GSigninManagerDelegate{
    func updateList(authorizer: GIDGoogleUser) {
        GDriveManager.shared.setAuthorizer(authorizer: authorizer.authentication.fetcherAuthorizer())
        self.downloadFilelist()
    }
}


