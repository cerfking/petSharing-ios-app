//
//  ClubViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/10.
//

import UIKit


struct ClubCollectionCellModel {
    let clubName:String
    let imageName:String?
    //let handler:(()->Void)
}

class ClubViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var collecitonView:UICollectionView?
    
    private var data = [ClubCollectionCellModel]()
    
    private let clubNames = ["Golden Retriever","Husky","Corgi","Samoyed","Shiba Inu","French Bulldog","Doberman","Poodle","Labrador"]
    
    private let posterImageView:UIImageView = {
        let posterImageView = UIImageView()
        posterImageView.sd_setImage(with: URL(string: "https://i0.wp.com/tccanines.com/wp-content/uploads/2016/10/SliderDogCrowd.png?w=2025&ssl=1"))
      //  posterImageView.image = UIImage(named: "usc_trojan_tommy_trojan_statue")
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.masksToBounds = true
        return posterImageView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureModels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        view.addSubview(posterImageView)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let size = (view.width - 2)/3
        layout.itemSize = CGSize(width: size, height: size)
        collecitonView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecitonView?.backgroundColor = .systemBackground
        collecitonView?.register(ClubCollectionViewCell.self, forCellWithReuseIdentifier: ClubCollectionViewCell.identifier)
        collecitonView?.delegate = self
        collecitonView?.dataSource = self
        guard let collectionView = collecitonView else {
            return
        }
        view.addSubview(collectionView)
        
        
        title = "Club"

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        posterImageView.snp.makeConstraints{ make in
//            make.left.equalToSuperview()
//            make.top.equalTo(navigationController!.navigationBar.snp.bottom)
//            make.width.equalTo(view.width)
//            make.height.equalTo(130)
//        }
        collecitonView?.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(view.width)
            make.top.equalTo(navigationController!.navigationBar.snp.bottom)
            make.height.equalTo(view.width)
        }
        posterImageView.snp.makeConstraints{ make in
            make.left.equalToSuperview()
           // make.top.equalTo(collecitonView!.snp.bottom)
            make.bottom.equalTo(tabBarController!.tabBar.snp.top)
            make.width.equalTo(view.width)
            make.height.equalTo(130)
        }
    }
    
    private func configureModels(){
        data.append(ClubCollectionCellModel(clubName: "Golden Retriever", imageName: "golden-retriever"))
        data.append(ClubCollectionCellModel(clubName: "Husky", imageName: "husky1"))
        data.append(ClubCollectionCellModel(clubName: "Corgi", imageName: "corgi1"))
        data.append(ClubCollectionCellModel(clubName: "Samoyed", imageName: "samoyed1"))
        data.append(ClubCollectionCellModel(clubName: "Shiba Inu", imageName: "shiba-inu"))
        data.append(ClubCollectionCellModel(clubName: "French Bulldog", imageName: "french-bulldog"))
        data.append(ClubCollectionCellModel(clubName: "Doberman", imageName: "doberman1"))
        data.append(ClubCollectionCellModel(clubName: "Poodle", imageName: "poodle1"))
        data.append(ClubCollectionCellModel(clubName: "Labrador", imageName: "labrador-retriever"))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClubCollectionViewCell.identifier, for: indexPath) as! ClubCollectionViewCell
        let model = data[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = CertainClubViewController(clubName: clubNames[indexPath.row])
        vc.title = clubNames[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }

}
