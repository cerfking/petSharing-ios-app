//
//  ChatViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/14.
//

import UIKit
import MessageKit
import LeanCloud
import InputBarAccessoryView
import SDWebImage
import SKPhotoBrowser
import AVFoundation

struct Message:MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender:SenderType {
    
    var photoURL: URL
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Audio:AudioItem {
    var url: URL
    
    var duration: Float
    
    var size: CGSize
    
}

class ChatViewController: MessagesViewController {
    
    
    public let otherUser:LCUser
    
    private var messages = [Message]()
    
    private var selfSender:Sender?
    
    private var conversation:IMConversation?
    
    private var recordingSession: AVAudioSession!
    
    private var audioRecorder: AVAudioRecorder!
    
    private var audioMessageURL:URL?
    
    private var player:AVPlayer?
    
    init(user:LCUser,conversation:IMConversation?) {
        self.conversation = conversation
        self.otherUser = user
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let recordButton:UIButton = {
        let recordButton = UIButton()
        recordButton.setTitle("按住说话", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchDown)
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(stopRecording), for: .touchUpOutside)
        return recordButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        
        messageInputBar.backgroundView.backgroundColor = .systemBackground
    
        
        DatabaseManager.shared.getUser(user: LCApplication.default.currentUser!) { [weak self] user in
            self?.selfSender = Sender(photoURL: (user?.profilePhoto)!, senderId: (user?.objectId)!, displayName: (user?.nickname)!)
        }
        
        //create conversation
        ConversationManager.shared.createNewConversation(targetUser: self.otherUser,completion: { [weak self] conversation in
            guard let _ = conversation else {
                return
            }
            self?.conversation = conversation
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("newMessageReceived"), object: nil, queue: .main, using: {[weak self] notification in
            guard let object = notification.object as? Message else{
                return
            }
            self?.messages.append(object)
            print(object)
            self?.listenForMessages(conversation: (self?.conversation)!, shouldScrollToBottom: true)
        })
        
        //请求录制语音的权限
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
            }
        } catch {
            // failed to record!
        }
    
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversation = conversation {
            listenForMessages(conversation: conversation, shouldScrollToBottom: true)
        }
    }
    
    private func setupInputButton(){
        let sendButton = messageInputBar.sendButton  //消息发送按钮
        let button = InputBarButtonItem() //添加照片按钮
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.tintColor = .label
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentImagePicker()
        }
        let audioButton = InputBarButtonItem() //发送语音按钮
        audioButton.setSize(CGSize(width: 35, height: 35), animated: false)
        audioButton.tintColor = .label
        audioButton.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
        audioButton.onTouchUpInside { [weak self] _ in
            self?.didTapAudioButton()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setStackViewItems([audioButton,sendButton], forStack: .right, animated: false)
        
    }
    
    //弹出图片选择界面
    private func presentImagePicker(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true)
    }
    private func didTapTextButton(){
        let sendButton = messageInputBar.sendButton
        messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        let audioButton = InputBarButtonItem() //发送语音按钮
        audioButton.setSize(CGSize(width: 35, height: 35), animated: false)
        audioButton.tintColor = .label
        audioButton.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
        audioButton.onTouchUpInside { [weak self] _ in
            self?.didTapAudioButton()
        }
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)
        messageInputBar.setStackViewItems([audioButton,sendButton], forStack: .right, animated: false)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    private func didTapAudioButton(){

        recordButton.frame = messageInputBar.inputTextView.frame
        messageInputBar.setMiddleContentView(recordButton, animated: false)
        //发送语音按钮变为编辑文字按钮
        let sendButton = messageInputBar.sendButton  //消息发送按钮
        let textButton = InputBarButtonItem()
        textButton.setSize(CGSize(width: 35, height: 35), animated: false)
        textButton.tintColor = .label
        textButton.setImage(UIImage(systemName: "keyboard"), for: .normal)
        textButton.onTouchUpInside { [weak self] _ in
            self?.didTapTextButton()
        }
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)
        messageInputBar.setStackViewItems([textButton,sendButton], forStack: .right, animated: false)
    }
    //获取该对话的所有信息
    private func listenForMessages(conversation:IMConversation, shouldScrollToBottom:Bool){
        ConversationManager.shared.getAllMessagesForConversation(conversation: conversation){ [weak self] results in
            guard !results!.isEmpty else {
                print("未收到消息")
                return
            }
            self?.messages = results!
            DispatchQueue.main.async {
                self?.messagesCollectionView.reloadDataAndKeepOffset()
                if shouldScrollToBottom {
                    self?.messagesCollectionView.scrollToLastItem()
                }
                
            }
        }
    }
    
    //MARK:--录制语音相关函数
    @objc func didTapRecordButton(){
        if audioRecorder == nil {
              startRecording()
          } else {
              finishRecording()
          }
    }
    
    private func startRecording(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioMessageURL = audioRecorder.url
                audioRecorder.delegate = self
                audioRecorder.record()
                recordButton.setTitle("停止录制", for: .normal)
            } catch {
                finishRecording()
            }
    }
    
    private func finishRecording(){
        audioRecorder.stop()
        audioRecorder = nil
        recordButton.setTitle("录制成功", for: .normal)
        //在这里直接执行录制完成后的发送操作
        guard let _ = audioMessageURL else {
            return
        }
        ConversationManager.shared.sendAudioMessage(conversation: conversation!, audioFileURL: audioMessageURL!){ [weak self] success,audioMessage in
            if success{
                let messageId = audioMessage?.ID
                let sender = self?.selfSender
                let audio = Audio(url: (audioMessage?.url)!, duration: Float((audioMessage?.duration)!), size: .zero)
                let newMessage = Message(sender: sender!, messageId: messageId!, sentDate: (audioMessage?.sentDate)!, kind: .audio(audio))
                self?.messages.append(newMessage)
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
                print("发送成功")
            }
            else {
                print("发送失败")
            }
            
            let fileManager = FileManager.default
            guard let destination = self?.audioMessageURL else {
                return
            }
            try? fileManager.removeItem(at: destination)
            
        }
        
    }
    
    @objc func stopRecording(){
        //取消录制
        audioRecorder.stop()
        audioRecorder = nil
        let fileManager = FileManager.default
        guard let _ = audioMessageURL else {
            return
        }
        try? fileManager.removeItem(at: audioMessageURL!)
        recordButton.setTitle("按住说话", for: .normal)
    }
    
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0]
    }
    
}
extension ChatViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording()
        }
    }
}

//MARK:--

extension ChatViewController:InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender else {
                return
        }
        print("发送中：\(text)")
        ConversationManager.shared.sendMessage(conversation: conversation!,message: text){ [weak self] success,message in
            if success {
                let messageId = message?.ID
                let sender = selfSender
                let result = convertStringToDictionary(text:(message?.content?.string)!)
                let messageContent = result?["_lctext"]
                let newMessage = Message(sender: sender, messageId: messageId!, sentDate: (message?.sentDate)!, kind: .text(messageContent as! String))
                self?.messages.append(newMessage)
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
                print("发送成功")
                inputBar.resignFirstResponder()
                inputBar.inputTextView.text = nil
            }
            else {
                print("发送失败")
            }
        }
    }
    
}

extension ChatViewController:MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil")
      
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            imageView.sd_setImage(with: imageURL)
        default:
            break
        }
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .audio(let audio):
            cell.durationLabel.text  = audio.duration.stringValue
        default:
            break
        }
    }
    
    //头像
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let message = messages[indexPath.section]
        let sender = message.sender as! Sender
        avatarView.sd_setImage(with: sender.photoURL, completed: nil)
    }
    
    //气泡颜色
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let message = messages[indexPath.section]
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .systemBlue
        }
        return .tertiarySystemGroupedBackground
    }
    //发送时间
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.section]
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "MM-dd HH:mm"
        let date = formatter.string(from: message.sentDate)
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12),.foregroundColor:UIColor.secondaryLabel]
        let attributeString = NSAttributedString(string: date, attributes: attributes)
        return attributeString
    }
}


extension ChatViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)

        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        ConversationManager.shared.sendImageMessage(conversation: conversation!, image: image){ [weak self] success,imageMessage in
            if success{
                let messageId = imageMessage?.ID
                let sender = self?.selfSender
                let media = Media(url: imageMessage?.url, image: image, placeholderImage: UIImage(named: "placeholderImage")!, size: .zero)
                let newMessage = Message(sender: sender!, messageId: messageId!, sentDate: (imageMessage?.sentDate)!, kind: .photo(media))
                self?.messages.append(newMessage)
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
                print("发送成功")
            }
            else {
                print("发送失败")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension ChatViewController:MessageCellDelegate{
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            let SKImages:[SKPhoto] = [SKPhoto.photoWithImageURL(imageURL.stringValue!)]
            let browser = SKPhotoBrowser(photos: SKImages)
            browser.initializePageIndex(indexPath.section)
            present(browser, animated: false)
        default:
            break
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case .audio(let audio):
            let playerItem = AVPlayerItem(url: audio.url)
            self.player = AVPlayer(playerItem:playerItem)
            player!.volume = 1.0
            player!.play()
        default:
            break
        }
      
    }
}
