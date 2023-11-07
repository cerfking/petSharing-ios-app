
import UIKit
import Kingfisher
import SnapKit
import LeanCloud

//定义枚举 富文本链接类型
enum SLTextLinkType: Int {
    case Webpage
    case Picture
    case FullText
}

//代理方法
@objc protocol SLTableViewCellDelegate : NSObjectProtocol {
    func tableViewCell(_ tableViewCell: SLTableViewCell, tapImageAction indexOfImages:NSInteger, indexPath: IndexPath)  //点击图片
    func tableViewCell(_ tableViewCell: SLTableViewCell, clickedLinks url:String,  characterRange: NSRange, linkType: SLTextLinkType.RawValue, indexPath: IndexPath)  //点击文本链接
}

//标题富文本视图
class SLTextView: UITextView {
    //关闭高亮富文本的长按选中功能
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is  UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false;
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
    //打开或禁用复制，剪切，选择，全选等功能 UIMenuController
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 返回false为禁用，true为开启
        if action == #selector(copy(_ :)) || action == #selector(selectAll(_ :)) || action == #selector(select(_ :)) {
            return true
        }
        return false
    }
}

class SLTableViewCell: UITableViewCell {
    
    weak var parent:UIViewController?

    
    //头像
    lazy var headImage: UIImageView = {
        let headimage = UIImageView()
        headimage.clipsToBounds = true
        headimage.layer.masksToBounds = true
        headimage.contentMode = .scaleAspectFit
        headimage.layer.cornerRadius = 25
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        headimage.isUserInteractionEnabled = true
        headimage.addGestureRecognizer(tapGestureRecognizer)
        return headimage
    }()
    //昵称
    lazy var nickLabel: UILabel = {
        let nickName = UILabel()
        nickName.textColor = .label;
        nickName.font = UIFont.systemFont(ofSize: 16)
        return nickName
    }()
    //时间和来源
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.textColor = UIColor.gray;
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        return timeLabel
    }()
    //标题
    lazy var textView: SLTextView = {
        let textView = SLTextView()
        textView.backgroundColor = .none
        textView.textColor = .label;
        textView.isEditable = false;
        textView.isScrollEnabled = false;
        textView.delegate = self
        textView.textDragInteraction?.isEnabled = false
        //内容距离行首和行尾的内边距
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        return textView
    }()
    //定位图标
    lazy var locationIcon:UIImageView = {
        let locationIcon = UIImageView()
        locationIcon.isHidden = true
        locationIcon.image = UIImage(named: "dingwei")
        locationIcon.contentMode = .scaleAspectFit
        return locationIcon
    }()
    //地理位置标签
    lazy var locationLabel:UILabel = {
        let locationLabel = UILabel()
        locationLabel.numberOfLines = 1
        //locationLabel.isHidden = true
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        return locationLabel
    }()
    //点赞按钮
    lazy var likeButton:UIButton = {
        let likeButton = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
        let image = UIImage(systemName: "hand.thumbsup",withConfiguration: config)
        let image2 = UIImage(systemName: "hand.thumbsup.fill",withConfiguration: config)
        likeButton.setImage(image, for: UIControl.State.normal)
        likeButton.tintColor = .label
        likeButton.setTitle(" Like", for: UIControl.State.normal)
        likeButton.setTitleColor(.secondaryLabel, for: .normal)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return likeButton
    }()
    //评论按钮
    lazy var commentButton:UIButton = {
        let commentButton = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
        let image = UIImage(systemName: "ellipses.bubble",withConfiguration: config)
        commentButton.setImage(image, for: UIControl.State.normal)
        commentButton.tintColor = .label
        commentButton.setTitle(" Comment", for: UIControl.State.normal)
        commentButton.setTitleColor(.secondaryLabel, for: .normal)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        
        return commentButton
    }()
    //图片视图数组
    var picsArray: [AnimatedImageView] = []
    //当前cell索引
    var cellIndexPath: IndexPath?
    // 代理
    weak var delegate: SLTableViewCellDelegate?
    
    //=========================================================
    var info:LCUser?
    var post:LCObject?
    
    //初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPost(tap:))))
    }
    
    // MARK: UI
    private  func setupUI() {
        self.selectionStyle = .none
        self.contentView.addSubview(self.headImage)
        self.contentView.addSubview(self.nickLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.locationIcon)
        self.contentView.addSubview(self.locationLabel)
        self.contentView.addSubview(self.likeButton)
        self.contentView.addSubview(self.commentButton)
        for i in 0..<9 {
            let imageView = AnimatedImageView(frame: CGRect.zero)
            imageView.backgroundColor = UIColor.lightGray
            imageView.isHidden = true
            imageView.tag = i
            imageView.autoPlayAnimatedImage = false
           
            imageView.framePreloadCount = 1
            imageView.isUserInteractionEnabled = true
            self.contentView.addSubview(imageView)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapPicture(tap:)))
            imageView.addGestureRecognizer(tap)
            self.picsArray.append(imageView)
        }
        
        self.headImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.width.equalTo(50)
        }
        self.nickLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImage.snp.right).offset(5)
            make.top.equalTo(self.headImage.snp.top).offset(5)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(self.contentView).offset(-80)
        }
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImage.snp.right).offset(5)
            make.top.equalTo(self.nickLabel.snp.bottom).offset(5)
            make.height.equalTo(10)
            make.right.lessThanOrEqualTo(self.contentView).offset(-80)
        }
        self.textView.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImage.snp.left)
            make.right.equalTo(self.contentView).offset(-15)
            make.top.equalTo(self.headImage.snp.bottom).offset(15)
            make.bottom.lessThanOrEqualToSuperview()
        }
        self.locationIcon.snp.makeConstraints{(make) in
            make.left.equalTo(self.contentView.snp.left).offset(15)
            make.width.equalTo(15)
            make.bottom.equalTo(self.commentButton.snp.top)
            make.height.equalTo(15)
        }
        self.locationLabel.snp.makeConstraints{(make) in
            make.left.equalTo(self.locationIcon.snp.right)
            make.right.equalTo(self.contentView.snp.right)
            make.bottom.equalTo(self.commentButton.snp.top)
            make.height.equalTo(15)
        }
        self.commentButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(20)
            make.width.equalTo(self.contentView.width / 2)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            make.height.equalTo(40)
        }
        self.likeButton.snp.makeConstraints{ (make) in
            make.width.equalTo(self.contentView.width / 2)
            make.right.equalTo(self.contentView.snp.right).offset(-20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            make.height.equalTo(40)
        }
        
    }
    
    // MARK: ReloadData
    func configureCell(model: Post, layout: SLLayout?) -> Void {
        if let _ = parent as? CertainPostViewController{
            self.commentButton.isHidden = true
            self.likeButton.isHidden = true
        }
        DatabaseManager.shared.getUser(user: model.poster!){ poster in
            let url = poster?.profilePhoto ?? URL(string:"https://hk3dpa.org/wp-content/uploads/2019/11/Network-Profile.png")
            let placeholderImage = UIImage(named: "placeholderImage")!
            let roundCornerProcessor = RoundCornerImageProcessor(cornerRadius: 350)
            self.headImage.kf.setImage(with: url!, placeholder:placeholderImage ,options: [.processor(roundCornerProcessor)])
            self.nickLabel.text = poster?.nickname
        }
        
        if model.time != nil && model.source != nil {
            self.timeLabel.text =  model.time! + " from " + model.source!
        }
        
        //self.timeLabel.text =  model.time! + " 来自 " + model.source!
        self.textView.attributedText = layout?.attributedString
        self.textView.textColor = .label
        if model.location != nil {
            self.locationIcon.isHidden = false
            self.locationLabel.text = model.location
        }
        
        //self.info = model.poster
        //获取post传入点赞函数
        
        let group = DispatchGroup()
        let query = LCQuery(className: "Post")
        group.enter()
        let _ = query.get(model.postId!,cachePolicy: .onlyNetwork) { (result) in
            switch result {
            case .success(object: let post):
                self.post = post
                self.info = post.get("poster") as? LCUser
                
            case .failure(error: let error):
                print(error)
                //--------------
                let _ = query.get(model.postId!,cachePolicy: .onlyNetwork) { (result) in
                    switch result {
                    case .success(object: let post):
                        self.post = post
                        self.info = post.get("poster") as? LCUser
                        
                    case .failure(error: let error):
                        print(error)
                    }
                    
                }
                //---------------
            }
            do {
                group.leave()
            }
        }
        //是否点赞
        group.notify(queue: .main){
            let likerQuery = LCQuery(className: "PostLike")
            likerQuery.whereKey("liker", .equalTo(LCApplication.default.currentUser!))
            let postQuery = LCQuery(className: "PostLike")
            if self.post != nil {
                postQuery.whereKey("post", .equalTo(self.post!))
            }
           //postQuery.whereKey("post", .equalTo(self.post!))
            do{
                let query2 = try likerQuery.and(postQuery)
                if query2.count().intValue != 0{
                    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
                    let image2 = UIImage(systemName: "hand.thumbsup.fill",withConfiguration: config)
                    self.likeButton.setImage(image2, for: UIControl.State.normal)
                    self.likeButton.removeTarget(self, action: #selector(self.didTapLikeButton), for: .touchUpInside)
                    self.likeButton.addTarget(self, action: #selector(self.didTapCancelLikeButton), for: .touchUpInside)
                }
            }catch{
                print(error)
            }
        }
       
        //图片宽、高
        let width: CGFloat = (UIScreen.main.bounds.size.width - 15 * 2 - 5 * 2)/3
        let height: CGFloat = width
        for (index, imageView) in self.picsArray.enumerated() {
            if model.images.count > index {
                imageView.isHidden = false
               
                imageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.textView.snp.bottom).offset(5 + (index/3) * Int(height + 5))
                    make.left.equalTo(15 + (index%3) * Int(width + 5))
                    make.width.height.equalTo(height)
                }     
                //URL编码
                let encodingStr = model.images[index].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageUrl = URL(string:encodingStr!)
                // 高分辨率的图片采取降采样的方法提高性能
                let processor = DownsamplingImageProcessor(size: CGSize(width: width, height: width))
                //性能优化 取消之前的下载任务
                imageView.kf.cancelDownloadTask()
                imageView.kf.setImage(with: imageUrl!, placeholder: nil, options: [.processor(processor), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage, .onlyLoadFirstFrame] , progressBlock: { (receivedSize, totalSize) in
                    //下载进度
                }) { (result) in
                    switch result {
                    case .success(let value):
                        let image: KFCrossPlatformImage = value.image
                        imageView.image = image
                        if (image.size.height/image.size.width > 3) {
                            //大长图 仅展示顶部部分内容
                            let proportion: CGFloat = height/(width * image.size.height/image.size.width)
                            imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: proportion)
                        } else if image.size.width >= image.size.height {
                            // 宽>高
                            let proportion: CGFloat = width/(height * image.size.width/image.size.height)
                            imageView.layer.contentsRect = CGRect(x: (1 - proportion)/2, y: 0, width: proportion, height: 1)
                        }else if image.size.width < image.size.height {
                            //宽<高
                            let proportion: CGFloat = height/(width * image.size.height/image.size.width)
                            imageView.layer.contentsRect = CGRect(x: 0, y: (1 - proportion)/2, width: 1, height: proportion)
                        }
                        //淡出动画
                        if value.cacheType == CacheType.none {
                            let fadeTransition: CATransition = CATransition()
                            fadeTransition.duration = 0.15
                            fadeTransition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
                            fadeTransition.type = CATransitionType.fade
                            imageView.layer.add(fadeTransition, forKey: "contents")
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
            } else {
                imageView.isHidden = true
                imageView.snp.remakeConstraints { (make) in
                    make.top.left.width.height.equalTo(0)
                }
            }
        }
    }
    
    // MARK: Events
    
    @objc func tapPost(tap: UITapGestureRecognizer){
        //_ = tap.view as! UIView
        if let _ = parent as? HomeViewController {
            let destinationVC = CertainPostViewController(post: self.post!)
            destinationVC.hidesBottomBarWhenPushed = true
            parent?.navigationController?.pushViewController(destinationVC,animated:true)
        }
    }
   
    @objc func tapPicture(tap: UITapGestureRecognizer) {
        let animationView: AnimatedImageView = tap.view as! AnimatedImageView
        if (self.delegate?.responds(to: #selector(SLTableViewCellDelegate.tableViewCell(_:tapImageAction:indexPath:))))! {
            self.delegate?.tableViewCell(self, tapImageAction: animationView.tag, indexPath: self.cellIndexPath!)
        }
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        let destinationVC = CertainUserViewController(user:self.info!)
        destinationVC.hidesBottomBarWhenPushed = true
        if let _ = parent as? HomeViewController{
            parent?.navigationController?.pushViewController(destinationVC,animated:true)
        }
        
    }
    @objc func didTapLikeButton(){
        StorageManager.shared.likePost(post: post!)
        DispatchQueue.main.async {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
            let image = UIImage(systemName: "hand.thumbsup.fill",withConfiguration: config)
            self.likeButton.setImage(image, for: UIControl.State.normal)
            self.likeButton.removeTarget(self, action: #selector(self.didTapLikeButton), for: .touchUpInside)
            self.likeButton.addTarget(self, action: #selector(self.didTapCancelLikeButton), for: .touchUpInside)
           
        }
        print("点赞成功")
    }
    @objc func didTapCancelLikeButton(){
        StorageManager.shared.CancelLikePost(post: post!)
        DispatchQueue.main.async {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
            let image = UIImage(systemName: "hand.thumbsup",withConfiguration: config)
            self.likeButton.setImage(image, for: UIControl.State.normal)
            self.likeButton.removeTarget(self, action: #selector(self.didTapCancelLikeButton), for: .touchUpInside)
            self.likeButton.addTarget(self, action: #selector(self.didTapLikeButton), for: .touchUpInside)
           
        }
        print("已取消点赞")
    }
    @objc func didTapCommentButton(){
        let vc = CommentPostViewController(post:self.post!)
        vc.title = "Comment"
        parent?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

// MARK: UITextViewDelegate
extension SLTableViewCell : UITextViewDelegate {
    //点击链接
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        var linkType: SLTextLinkType = SLTextLinkType.Webpage
        if URL.absoluteString == "FullText" {
            linkType = SLTextLinkType.FullText
        }
        self.delegate?.tableViewCell(self, clickedLinks: URL.absoluteString, characterRange: characterRange, linkType: linkType.rawValue, indexPath: self.cellIndexPath!)
        return false
    }
    //点击富文本附件 图片等
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
       
        return false
    }
}

