//
//  EnterVerifyCodeViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/25.
//

import UIKit
import MHVerifyCodeView
import LeanCloud

class EnterVerifyCodeViewController: UIViewController {
    
    private let mobilePhoneNumber:String
    
    init(mobilePhoneNumber:String) {
        self.mobilePhoneNumber = mobilePhoneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Code"
        let font:UIFont = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.init(4))
        label.font = font
        return label
    }()
    
    private let verifyCodeView:MHVerifyCodeView = {
        let verifyCodeView = MHVerifyCodeView()
        let height:CGFloat = 50
        let width: CGFloat = height * CGFloat(6) + 10 * CGFloat(6 - 1)
        verifyCodeView.spacing = 10
        verifyCodeView.verifyCount = 6
        verifyCodeView.frame = CGRect(
            x:20,
            y:170,
            width: width,
            height: height
        )

        return verifyCodeView
    }()
    
    @IBOutlet var resendButton:UIButton! = {
        let resendButton = UIButton()
        resendButton.frame = CGRect(x: 20, y: 240, width: 200, height: 40)
        
        return resendButton
    }()
    
    var countdownTimer:Timer?
    var remainingSeconds:Int = 0{
        willSet{
            resendButton.setTitle("Resend(\(newValue))", for: .normal)
            resendButton.setTitleColor(.black, for: .normal)
            if newValue <= 0 {
                resendButton.setTitle("Resend", for: .normal)
                iscounting = false
            }
        }
    }
    var iscounting = false{
        willSet{
            if newValue{
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)
                remainingSeconds = 60
                resendButton.backgroundColor = .systemGray
            }else{
                //结束记时
                countdownTimer?.invalidate() //关闭计时
                countdownTimer = nil
                resendButton.backgroundColor = .systemBlue
            }
            resendButton.isEnabled = !newValue
        }
    }
    
    @objc func sendButtonClick(_ sender:UIButton){
        iscounting = true
        _ = LCSMSClient.requestShortMessage(mobilePhoneNumber:mobilePhoneNumber,signatureName: "NCUTer"){ (result) in
            switch result {
                case .success:
                    print("发送成功")
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
    }
    
    @objc func updateTime(_ timer:Timer){
        remainingSeconds -= 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: 100, width: view.width, height: 50)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        iscounting = true
        resendButton.addTarget(self, action: #selector(sendButtonClick(_:)), for: .touchUpInside)
        view.backgroundColor = .systemBackground
        view.alpha = 1
        verifyCodeView.setCompleteHandler(complete: { [weak self] (vc) in
            AuthManager.shared.registerWithCode(mobilePhoneNumber: "14701545412", verificationCode: vc){ success in
                if success {
                    let alert = UIAlertController(title: "注册成功", message: "即将进入主页面", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler:{ _ in
                        let homeVC = HomeViewController()
                        homeVC.modalPresentationStyle = .fullScreen
                        self?.present(homeVC, animated: true, completion: nil)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "注册失败", message: "用户已存在，请登录", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: { _ in
                        self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
           
        })
        view.addSubview(verifyCodeView)
        view.addSubview(label)
        view.addSubview(resendButton)
        
        //---------
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}




