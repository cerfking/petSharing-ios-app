//
//  ARViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/28.
//

import UIKit
import ARKit
import QuickLook
import RealityKit
import Alamofire


class ARViewController: UIViewController, QLPreviewControllerDataSource{
    
    static let shared = ARViewController()
    
    
    // 1
    var modelURL: URL?
    
    
    
    private var observation: NSKeyValueObservation?
    
    deinit {
        observation?.invalidate()
      }

    private let previewButton:UIButton = {
        let previewButton = UIButton()
        previewButton.backgroundColor = .green
        previewButton.setTitle("AR", for: .normal)
        return previewButton
    }()
    private let downloadButton:UIButton = {
        let downloadButton = UIButton()
        downloadButton.backgroundColor = .blue
        downloadButton.setTitle("下载模型", for: .normal)
        return downloadButton
    }()
    private let progressView:UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = .gray
        progressView.progressTintColor  = .systemBlue
        return progressView
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(previewButton)
        view.addSubview(downloadButton)
        view.addSubview(progressView)
        progressView.setProgress(0, animated: false)
        previewButton.addTarget(self, action: #selector(startDecoratingButtonPressed), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadSampleUSDZ), for: .touchUpInside)
       
        // 2
        self.clearAllFilesFromDirectory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewButton.frame = CGRect(x: 60, y: 200, width: 100, height: 60)
        
        downloadButton.frame = CGRect(x: 60, y: 300, width: 100, height: 60)
        
        progressView.frame = CGRect(x: 10, y: 100, width: view.width - 20, height: 10)
    }
    
  
   
    
    @objc func startDecoratingButtonPressed() {
        
        // 3
        guard modelURL != nil else { return }
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
        
    }
    
    // 4
    @objc func downloadSampleUSDZ() {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)

        AF.download("https://httpbin.org/image/png", to: destination).responseURL{ response in
            print(response)
        }
        
            
            let url = URL(string: "http://ins.cerf.top/a6v7juJBS0RStMDmmteSMarRbz5nLCqz/store%20-%20legolas.usdz")!
            if FileManager.default.fileExists(atPath: url.path) {
                try! FileManager.default.removeItem(at: url)

            }
        
        
            let downloadTask = URLSession.shared.downloadTask(with: url) { urlOrNil, responseOrNil, errorOrNil in
             
             guard let fileURL = urlOrNil else { return }
             do {
               
                 let documentsURL = try
                     FileManager.default.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: false)
                 let savedURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
                 self.modelURL = savedURL
                print(savedURL)
             } catch {
                
                print ("file error: \(error)")
             }

         }
        
        observation = downloadTask.progress.observe(\.fractionCompleted) { progress, _ in
             print("progress: ", progress.fractionCompleted)
            
            DispatchQueue.main.async {
                self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
                    
                
            
            
           }
         downloadTask.resume()
            
            
    }
    

    
    public func clearAllFilesFromDirectory() {

       let fileManager = FileManager.default
       let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
       let documentsPath = documentsUrl.path

       do {
           if let documentPathValue = documentsPath{

               let path = documentPathValue.replacingOccurrences(of: "file://", with: "")
               let fileNames = try fileManager.contentsOfDirectory(atPath: "\(path)")
               print("all files in cache: \(fileNames)")

               for fileName in fileNames {

                   let tempPath = String(format: "%@/%@", path, fileName)

                   //Check for specific file which you want to delete. For me .usdz files
                   if tempPath.contains(".usdz") {
                       try fileManager.removeItem(atPath: tempPath)
                   }
               }
           }

       } catch {
           print("Could not clear document directory \(error)")
       }
   }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
       
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        let previewItem = ARQuickLookPreviewItem(fileAt: self.modelURL!)
        previewItem.canonicalWebPageURL = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/vintagerobot2k/")
        previewItem.allowsContentScaling = false
        return previewItem
        
    }
}



        
    


