//
//  GarbageClassificationViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/21.
//

import UIKit
import SnapKit
import CoreML
import Vision


class GarbageClassificationViewController: UIViewController, UINavigationControllerDelegate {
    
    private let recyclable:[String] = ["brown-glass","cardboard","clothes","green-glass","paper","plastic","shoes","white-glass"]
    
    private let other:[String] = ["trash"]
    
    private let kitchen:[String] = ["biological"]
    
    private let hazardous:[String] = ["battery","metal"]
    
    private var image:UIImage?
    
    private var result:String?
    
    private let posterImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ClassificationPoster")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "GarbageClassification")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let selectPhotoButton:UIButton = {
        let button = UIButton()
        button.setTitle("选择图片", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.titleEdgeInsets = UIEdgeInsets(top: 80, left: 0, bottom: 10, right: 0)
        let imageView = UIImageView(frame: CGRect(x: 25, y: 10, width: 70, height: 70))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        button.addSubview(imageView)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapSelectPhotoButton), for: .touchUpInside)
        button.backgroundColor = .systemGreen
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 60
        return button
    }()
    
    private let cameraButton:UIButton = {
        let button = UIButton()
        button.setTitle("拍照识别", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.titleEdgeInsets = UIEdgeInsets(top: 80, left: 0, bottom: 10, right: 0)
        let imageView = UIImageView(frame: CGRect(x: 25, y: 10, width: 70, height: 70))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "camera")
        button.addSubview(imageView)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        button.backgroundColor = .systemGreen
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 60
        return button
    }()
    

    @objc func didTapSelectPhotoButton(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
    }
    
    @objc func didTapCameraButton(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "垃圾分类助手"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isTranslucent = false
        view.addSubview(posterImageView)
        view.addSubview(imageView)
        view.addSubview(selectPhotoButton)
        view.addSubview(cameraButton)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        posterImageView.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(92)
            make.height.equalTo(120)
        }
        selectPhotoButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(120)
            make.top.equalTo(posterImageView.snp.bottom).offset(60)
        }
        cameraButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(120)
            make.bottom.equalTo(imageView.snp.top).offset(-60)
        }

        imageView.snp.makeConstraints{ make in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(150)
        }
        
    }
    
    private func classifyImage(image: CIImage) {
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: GarbageClassifier().model) else {
          fatalError("can't load Places ML model")
        }
        
        // Create a Vision request with completion handler
        let group = DispatchGroup()
        group.enter()
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let strongSelf = self else {
                return
            }
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            let outputText = "\(Int(results[0].confidence * 100))% 的概率是 \(results[0].identifier)\n"
            
            
            if (strongSelf.recyclable.contains(results[0].identifier)){
                strongSelf.result = "可回收物"
            }
            else if (strongSelf.other.contains(results[0].identifier)){
                strongSelf.result = "其他垃圾"
            }
            else if (strongSelf.kitchen.contains(results[0].identifier)) {
                strongSelf.result = "厨余垃圾"
            }
            else if (strongSelf.hazardous.contains(results[0].identifier)) {
                strongSelf.result = "有害垃圾"
            }
            print(outputText)
            group.leave()
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
          do {
            try handler.perform([request])
          } catch {
            print(error)
          }
            
        }
        group.notify(queue: .main){
            self.present(ResultViewController(image: self.image!, result: self.result!), animated: true)
        }
        

      }
}


extension GarbageClassificationViewController:UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)

        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        self.image = image

        guard let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }

        classifyImage(image: ciImage)
        
 }
    
    
}
