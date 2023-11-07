

import UIKit
import HandyJSON
import LeanCloud

// 数据模型
struct SLModel : HandyJSON {
    var headPic: String = ""
    var nickName: String?
    var time: String?
    var source: String?
    var title: String?
    var images: [String] = []
}
// 布局信息
struct SLLayout : HandyJSON {
    var attributedString: NSMutableAttributedString?
    var cellHeight: CGFloat = 0
    var expan: Bool = false //是否展开
}

//正则匹配规则


let KTitleLengthMax = 99  // 默认标题最多字符个数，但不固定，取决于高亮的字符是否会被截断
//数据请求完毕的回调Block
typealias SLGetDataCompleteBlock = (_ dataArray: NSMutableArray, _ layoutArray: NSMutableArray) ->Void
//标题全文点击回调
typealias SLFullTextCompleteBlock = (_ indexPath: IndexPath) ->Void

//中间者
class SLPresenter: NSObject{
    
    var dataArray = NSMutableArray()
    var layoutArray = NSMutableArray()
    //    var completeBlock: SLGetDataCompleteBlock?
    var fullTextBlock: SLFullTextCompleteBlock?
    // MARK: Data
    // @escaping 防止该参数在当前函数执行完成后释放，常用在异步操作中
    func getData(completeBlock: @escaping SLGetDataCompleteBlock) {
        self.dataArray.removeAllObjects()
        self.layoutArray.removeAllObjects()
        
        //async异步追加Block块（async函数不做任何等待）
        
            //处理耗时操作的代码块...
        DispatchQueue.main.async {
            DatabaseManager.shared.getPosts(){ posts in
                let posts = posts
                for post in posts! {
                    var model = Post()
                    model = post
                    self.dataArray.add(model)
                   
                
                   //元组
                    let attStrAndHeight:(attributedString:NSMutableAttributedString, height:CGFloat) = (self.matchesResultOfTitle(title: model.title ?? "", expan: false))
                let layout:SLLayout = SLLayout(attributedString: attStrAndHeight.attributedString, cellHeight: (80 + 70 + attStrAndHeight.height + (self.heightOfImages(images: model.images))), expan: false)
                self.layoutArray.add(layout)
                    
                }
                   
                    completeBlock(self.dataArray, self.layoutArray)
                
            }
        }
    }
    
    func getCertainUserData(user:LCUser,completeBlock: @escaping SLGetDataCompleteBlock) {
        self.dataArray.removeAllObjects()
        self.layoutArray.removeAllObjects()
        DispatchQueue.main.async {
            DatabaseManager.shared.getCertainUserPosts(user: user){ posts in
                let posts = posts
                for post in posts! {
                    var model = Post()
                    model = post
                    self.dataArray.add(model)
                let attStrAndHeight:(attributedString:NSMutableAttributedString, height:CGFloat) = (self.matchesResultOfTitle(title: model.title!, expan: false))
                let layout:SLLayout = SLLayout(attributedString: attStrAndHeight.attributedString, cellHeight: (80 + 70 + attStrAndHeight.height + (self.heightOfImages(images: model.images))), expan: false)
                self.layoutArray.add(layout)
                    
                }
                   
                    completeBlock(self.dataArray, self.layoutArray)
                
            }
        }
    }
    
    func getCertainPost(post:LCObject,completeBlock: @escaping SLGetDataCompleteBlock) {
        self.dataArray.removeAllObjects()
        self.layoutArray.removeAllObjects()
        DispatchQueue.main.async {
            DatabaseManager.shared.getCertainPost(post: post){ post in
            
                var model = Post()
                model = post!
                self.dataArray.add(model)
                let attStrAndHeight:(attributedString:NSMutableAttributedString, height:CGFloat) = (self.matchesResultOfTitle(title: model.title!, expan: true))
                let layout:SLLayout = SLLayout(attributedString: attStrAndHeight.attributedString, cellHeight: (80 + 70 + attStrAndHeight.height + (self.heightOfImages(images: model.images))), expan: true)
                self.layoutArray.add(layout)
                    
                
                   
                    completeBlock(self.dataArray, self.layoutArray)
                
            }
        }
    }
    
    //标题正则匹配结果
    func matchesResultOfTitle(title: String, expan: Bool) -> (attributedString : NSMutableAttributedString , height : CGFloat) {
        //原富文本标题
        var attributedString:NSMutableAttributedString = NSMutableAttributedString(string:title)
       
        
        //最大字符 截取位置
        let cutoffLocation = KTitleLengthMax
        
       
        //超出字符个数限制，显示全文
        if attributedString.length > cutoffLocation {
            var fullText: NSMutableAttributedString
            if expan {
                attributedString.append(NSAttributedString(string:"\n"))
                fullText = NSMutableAttributedString(string:"Fold")
                fullText.addAttributes([NSAttributedString.Key.link :"FullText"], range: NSRange(location:0, length:fullText.length ))
            }else {
                attributedString = attributedString.attributedSubstring(from: NSRange(location: 0, length: cutoffLocation)) as! NSMutableAttributedString
                fullText = NSMutableAttributedString(string:"...Full Text")
                fullText.addAttributes([NSAttributedString.Key.link :"FullText"], range: NSRange(location:3, length:fullText.length - 3))
            }
            attributedString.append(fullText)
        }
        //段落
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 //行间距
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle :paragraphStyle, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], range: NSRange(location:0, length:attributedString.length))
        
        //元组
        let attributedStringHeight = (attributedString, heightOfAttributedString(attributedString))
        return attributedStringHeight
    }
    //根据匹配规则返回所有的匹配结果
    fileprivate func getRangesFromResult(regexStr : String, title: String) -> [NSRange] {
        // 0.匹配规则
        let regex = try? NSRegularExpression(pattern:regexStr, options: [])
        // 1.匹配结果
        let results = regex?.matches(in:title, options:[], range: NSRange(location: 0, length: NSAttributedString(string: title).length))
        // 2.遍历结果 数组
        var ranges = [NSRange]()
        for res in results! {
            ranges.append(res.range)
        }
        return ranges
    }
    //计算富文本的高度
    func heightOfAttributedString(_ attributedString: NSAttributedString) -> CGFloat {
        let height : CGFloat =  attributedString.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 15 * 2, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        return ceil(height)
    }
    //图组的高度
    func heightOfImages(images:[String]) -> CGFloat {
        if images.count == 0 {
            return 0
        } else {
            let picHeight = (UIScreen.main.bounds.size.width - 15 * 2 - 5 * 2)/3
            var height = 0
            
            height = ((images.count - 1)/3 + 1) * Int(picHeight) + (images.count - 1)/3 * 5 + 15
            
            return CGFloat(height);
        }
    }
}

// MARK: SLTableViewCellDelegate
extension SLPresenter : SLTableViewCellDelegate {
    //富文本点击跳转事件
    func tableViewCell(_ tableViewCell: SLTableViewCell, clickedLinks url: String, characterRange: NSRange, linkType: SLTextLinkType.RawValue, indexPath: IndexPath) {
    
      if linkType == SLTextLinkType.FullText.rawValue {
            let model: Post = self.dataArray[indexPath.section] as! Post
            var layout: SLLayout = self.layoutArray[indexPath.section] as! SLLayout
            layout.expan = !layout.expan
            //元组
            let attStrAndHeight:(attributedString:NSMutableAttributedString, height:CGFloat) = self.matchesResultOfTitle(title: model.title!, expan: layout.expan)
            layout.attributedString = attStrAndHeight.attributedString
            layout.cellHeight = (70 + 80  + attStrAndHeight.height + self.heightOfImages(images: model.images))
            self.layoutArray.replaceObject(at: indexPath.section, with: layout)
            self.fullTextBlock!(indexPath)
        }
       
    }
    
    //图片点击
    func tableViewCell(_ tableViewCell: SLTableViewCell, tapImageAction indexOfImages: NSInteger, indexPath: IndexPath) {
        let pictureBrowsingViewController:SLPictureBrowsingViewController = SLPictureBrowsingViewController.init()
        
       
        let model:Post = self.dataArray[indexPath.section] as! Post
        pictureBrowsingViewController.imagesArray = model.images
        pictureBrowsingViewController.currentPage = indexOfImages
        pictureBrowsingViewController.currentIndexPath = indexPath
        UIApplication.topViewController()?.present(pictureBrowsingViewController, animated: true, completion: nil)
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

