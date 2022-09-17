//
//  ViewController.swift
//  WLM3U
//
//  Created by Willie on 07/15/2019.
//  Copyright (c) 2019 Willie. All rights reserved.
//

import UIKit
import WLM3U
import M3U8Kit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var progressView1: UIProgressView!
    @IBOutlet weak var speedLabel1: UILabel!
    @IBOutlet weak var progressLabel1: UILabel!
    
    @IBOutlet weak var textView2: UITextView!
    @IBOutlet weak var progressView2: UIProgressView!
    @IBOutlet weak var speedLabel2: UILabel!
    @IBOutlet weak var progressLabel2: UILabel!
    
    let url1 = "https://hls.banyung.pw/m3u8.php?path=13ebf7b0cb27f8a15be7e76e95e5a252-20220916.m3u8"
    
    let url2 = "https://jisu-xhzy.com/videos/202208/08/62f0f645911a705ae4ef57df/7ca25f/index.m3u8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textView1?.text = url1
        textView2?.text = url2
    }
    
    @IBAction func onDownloadButton(_ sender: UIButton) {

        
        guard let url = URL(string: sender.tag == 0 ? url1 : url2) else {
            return

        }
        guard let parse = try? M3U8PlaylistModel(url: url) else {
            return
        }
        
        var array: [URL] = []
        guard let segmentList = parse.mainMediaPl.segmentList else { return  }
//        let count = segmentList.count
//        for index in 0..<count {
//            array.append(segmentList.segmentInfo(at: index).mediaURL())
//        }
        array = parse.mainMediaPl.allSegmentURLs() as? [URL] ?? []
        
        do {
            let workflow = try WLM3U.attach(url: url,
                                            size: array.count,
                                            tsURL: {

                return array
            },
                                            completion: { (result) in
                                                switch result {
                                                case .success(let model):
                                                    print("[Attach Success] " + model.name!)
                                                case .failure(let error):
                                                    print("[Attach Failure] " + error.localizedDescription)
                                                }
            })
            
            run(workflow: workflow, index: sender.tag)
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func onPauseButton(_ sender: UIButton) {
        WLM3U.cancel(url: URL(string: sender.tag == 0 ? textView1.text : textView2.text)!)
    }
    
    @IBAction func onResumeButton(_ sender: UIButton) {
        let url = URL(string: sender.tag == 0 ? textView1.text : textView2.text)!
        do {
            let workflow = try WLM3U.attach(url: url,
                                            completion: { (result) in
                                                switch result {
                                                case .success(let model):
                                                    print("[Attach Success] " + model.name!)
                                                case .failure(let error):
                                                    print("[Attach Failure] " + error.localizedDescription)
                                                }
            })
            
            run(workflow: workflow, index: sender.tag)
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func run(workflow: Workflow, index: Int) {
        
        let progressView = (index == 0 ? progressView1 : progressView2)!
        let speedLabel = (index == 0 ? speedLabel1 : speedLabel2)!
        let progressLabel = (index == 0 ? progressLabel1 : progressLabel2)!
        
        workflow
            
            .download(progress: { (progress, completedCount) in
                progressView.progress = Float(progress.fractionCompleted)
                var text = ""
                let mb = Double(completedCount) / 1024 / 1024
                if mb >= 0.1 {
                    text = String(format: "%.1f", mb) + " M/s"
                } else {
                    text = String(completedCount / 1024) + " K/s"
                }
                speedLabel.text = text
                progressLabel.text = String(format: "%.2f", progress.fractionCompleted * 100) + " %"
            }, completion: { (result) in
                switch result {
                case .success(let url):
                    print("[Download Success] " + url.path)
                case .failure(let error):
                    print("[Download Failure] " + error.localizedDescription)
                }
            })
            
            .combine(completion: { (result) in
                switch result {
                case .success(let url):
                    print("[Combine Success] " + url.path)
                case .failure(let error):
                    print("[Combine Failure] " + error.localizedDescription)
                }
                
                speedLabel.text = "All finished"
                progressLabel.text = "All finished"
            })
    }
}

