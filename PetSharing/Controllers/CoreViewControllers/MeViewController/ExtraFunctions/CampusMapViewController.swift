//
//  CampusMapViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/21.
//

import UIKit
import SDWebImage
import SnapKit

class CampusMapViewController: UIViewController {
    
    let mapURL = URL(string: "http://ins.cerf.top/jWRvVp2z80cs2Fyw7Es7yJVjS53Qhspu/usc-campus-map.jpg")
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = .systemBackground
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        return scrollView
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage()
        return imageView
    }()
    
    private func addGesture(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func didPinch(_ gesture:UIPinchGestureRecognizer){
        if gesture.state == .changed{
            let scale = gesture.scale
            imageView.frame = CGRect(x: 0, y: -40, width: view.width * scale, height: view.height * scale)
            scrollView.contentSize = CGSize(width: view.width * scale, height: view.height * scale)
        }
        if gesture.state == .ended && gesture.scale < 1 {
            imageView.frame = CGRect(x: 0, y: -40, width: view.width, height: view.height)
          }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Map"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isTranslucent = false
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 92, width: view.width, height: view.height)
        scrollView.contentSize = CGSize(width: view.width, height: view.height)
        scrollView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: -40, width: view.width, height: view.height)
        imageView.sd_setImage(with: mapURL)
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        addGesture()
    }
    
   
}
