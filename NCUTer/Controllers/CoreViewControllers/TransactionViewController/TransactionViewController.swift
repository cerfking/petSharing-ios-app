//
//  TransactionViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/10.
//

import UIKit
import CHTCollectionViewWaterfallLayout

class TransactionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    lazy var commodities = [Commodity]()
    

    
    private let collectionView:UICollectionView = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.itemRenderDirection = .leftToRight
        layout.columnCount = 2
        let collectionView = UICollectionView(frame: .init(), collectionViewLayout: layout)
        collectionView.register(SecondhandItemsCollectionViewCell.self, forCellWithReuseIdentifier: SecondhandItemsCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let button:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        //let image = UIImage(named: "sell")
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        button.backgroundColor = .systemYellow
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapButton(){
        let vc = NewCommodityViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.navigationBar.isTranslucent = true
        title = "Item"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(button)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        DispatchQueue.main.async {
            DatabaseManager.shared.getCommodities{ [weak self] commodities in
                if commodities?.count != 0 {
                    self?.commodities = commodities!
               
                }
                else {
                    return
                }
                self?.collectionView.reloadData()
            }
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.bottom.equalToSuperview().offset(-100)
            make.height.equalTo(60)
        }
//        button.frame = CGRect(x: view.width - 70, y: view.height - 100, width: 60, height: 60)
        
        collectionView.frame = CGRect(x: 10, y: 5, width: Int(view.width) - 20, height: Int(view.height))
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commodities.count
     
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SecondhandItemsCollectionViewCell.identifier, for: indexPath) as? SecondhandItemsCollectionViewCell else {
            fatalError()
        }
        
        cell.configure(commodity: commodities[indexPath.row])
        
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: CGFloat.random(in: 400...600) + 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = CertainCommodityViewController(commodity: commodities[indexPath.row])
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}
