//
//  GDriveManager.swift
//  MyGDrive
//
//  Created by 王冠之 on 2020/5/14.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GTMSessionFetcher

typealias GDUploadResult = (Bool, Error?) -> Void
typealias GDDownloadResult = (Data?, Error?) -> Void
typealias GDDeleteResult = GDUploadResult
typealias GDDownloadFileListResult = ([GTLRDrive_File]?, Error?) -> Void

protocol GDriveFileListDelegate: NSObject {
    func didUpdate(manager: GDriveManager, files: [GTLRDrive_File]?, error: Error?)
}

class GDriveManager {
    
    let drive = GTLRDriveService()
    
    weak var delegate: GDriveFileListDelegate?
    
    //Singleton
    static let shared = GDriveManager()
    private init() {
        //...
    }
    
    func setAuthorizer(authorizer: GTMFetcherAuthorizationProtocol){
        drive.authorizer = authorizer
    }
    
    func uploadFile(url: URL, mimeType: String, name: String, description: String, completion: @escaping GDUploadResult) {
        //Prepare GTLRDrive_File Object.
        let file = GTLRDrive_File()
        file.originalFilename = name
        file.name = name
        file.descriptionProperty = description
        file.mimeType = mimeType
        
        //Prepare parameters.
        let paremeters = GTLRUploadParameters(fileURL: url, mimeType: mimeType)
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: paremeters) //指令
        
        //Execute Query
        drive.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Upload Fail: \(error)")
                completion(false,error)
                return
            }
            print("UPload OK.")
            completion(true, nil)
        }
    }
    
    func downloadFile(identifier: String, completion: @escaping GDDownloadResult) {
        let urlString = String(format: "https://www.googleapis.com/drive/v2/files/\(identifier)?alt=media")
        let fetcher = drive.fetcherService.fetcher(withURLString: urlString)
        fetcher.beginFetch { (data, error) in
            completion(data, error)
        }
    }
    
    func deleteFile(identifier: String, completion: @escaping GDDeleteResult){
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: identifier)
        drive.executeQuery(query) { (ticket, result, error) in
            if let error = error{
                print("Fail tp delete file: \(error)")
                completion(false, error)
                return
            }
            completion(true, error)
        }
    }
    
    //MARK:- 取得檔案清單
    func downloadFilelist(completion: @escaping GDDownloadFileListResult){
        drive.shouldFetchNextPages = true
        let query = GTLRDriveQuery_FilesList.query()
        drive.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Upload Fail: \(error)")
                completion(nil, error)
                return
            }
            guard let result = result as? GTLRDrive_FileList, let files = result.files else {
                assertionFailure("Fail to get result.")
                let error = NSError(domain: "Invalid Result", code: -999, userInfo: nil)
                completion(nil, error)
                //completion(nil, error?.localizedDescription as? Error)
                return
            }
            print("Total: \(files.count)")
            completion(files, nil)
        }
    }
    
    func downloadFilelist2(){
        drive.shouldFetchNextPages = true
        let query = GTLRDriveQuery_FilesList.query()
        drive.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Upload Fail: \(error)")
                self.delegate?.didUpdate(manager: self, files: nil, error: error)
                return
            }
            guard let result = result as? GTLRDrive_FileList, let files = result.files else {
                assertionFailure("Fail to get result.")
                let error = NSError(domain: "Invalid Result", code: -999, userInfo: nil)
                self.delegate?.didUpdate(manager: self, files: nil, error: error)
                //completion(nil, error?.localizedDescription as? Error)
                return
            }
            print("Total: \(files.count)")
            self.delegate?.didUpdate(manager: self, files: files, error: nil)
        }
    }
}
