//
//  EditProfileViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/13.
//

import UIKit
import LeanCloud
import SDWebImage

struct EditProfileCellModel {
    let title:String
    var value:String?
    let handler:(()->Void)
}
struct EditProfileFormModel {
    let label:String
    //let placeholder:String
    var value:String?
}


class EditProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    private var gender:String?
    private var bio:String?
    private var observer:NSObjectProtocol?
    private let genderPicker:UIPickerView = {
        let genderPicker = UIPickerView()
        genderPicker.translatesAutoresizingMaskIntoConstraints = false
        genderPicker.backgroundColor = .secondarySystemBackground
        return genderPicker
    }()
    
    private let genderPickerToolBar:UIToolbar = {
        let genderPickerToolBar = UIToolbar(frame:CGRect(x: 0, y: 650, width: UIScreen.main.bounds.width, height: 50))
        genderPickerToolBar.translatesAutoresizingMaskIntoConstraints = false
        genderPickerToolBar.barStyle = .default
        genderPickerToolBar.isTranslucent = true
        genderPickerToolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSexPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "cancle", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneSexPicker))
        genderPickerToolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        genderPickerToolBar.isUserInteractionEnabled = true
        return genderPickerToolBar
    }()
    
    private let birthdayPicker:UIDatePicker = {
        let birthdayPicker = UIDatePicker()
        birthdayPicker.translatesAutoresizingMaskIntoConstraints = false
        birthdayPicker.locale = NSLocale(localeIdentifier: "en_us") as Locale
        birthdayPicker.timeZone = NSTimeZone.system
        birthdayPicker.preferredDatePickerStyle = .wheels
        birthdayPicker.datePickerMode = .date
        birthdayPicker.addTarget(self, action: #selector(getBirthday), for: UIControl.Event.valueChanged)
        birthdayPicker.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        birthdayPicker.layer.masksToBounds = true
        return birthdayPicker
        
    }()
    
    private let birthdayPickerToolBar:UIToolbar = {
        let birthdayPickerToolBar = UIToolbar(frame:CGRect(x: 0, y: 650, width: UIScreen.main.bounds.width, height: 50))
        birthdayPickerToolBar.translatesAutoresizingMaskIntoConstraints = false
        birthdayPickerToolBar.updateConstraintsIfNeeded()
        birthdayPickerToolBar.barStyle = .default
        birthdayPickerToolBar.isTranslucent = true
        birthdayPickerToolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneBirthdayPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "cancle", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneBirthdayPicker))
        birthdayPickerToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        birthdayPickerToolBar.isUserInteractionEnabled = true
        return birthdayPickerToolBar
    }()
    
   
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isHidden = false
        tableView.register(ProfileImageTableViewCell.self, forCellReuseIdentifier: ProfileImageTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(EditTableViewCell.self, forCellReuseIdentifier: EditTableViewCell.identifier)
        return tableView
    }()
    private var data = [EditProfileCellModel]()
    
    private var models = [EditProfileFormModel]()
    
    private var profileURL:URL?
    
    
    private func configureModels(){
        data.removeAll()
        DatabaseManager.shared.getUser(user:LCApplication.default.currentUser!){[weak self] user in
            let gender2 = user?.gender
            let bio = user?.bio
            let nickname = user?.nickname
            let birthday = user?.birthday
            
            DispatchQueue.main.async {
                self?.data.append(EditProfileCellModel(title: "Gender",value: gender2){
                    [weak self] in
                    self?.didTapGender()
                }
                )
                self?.data.append(EditProfileCellModel(title: "Nickname",value: nickname){
                    [weak self] in
                    self?.didTapGender()
                }
                )
                self?.data.append(EditProfileCellModel(title: "Birthday",value: birthday){
                    [weak self] in
                    self?.didTapGender()
                }
                )
                self?.data.append(EditProfileCellModel(title: "Bio",value: bio){
                    [weak self] in
                    self?.didTapGender()
                }
                )
                self?.profileURL = user?.profilePhoto
                
                self?.tableView.reloadData()
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(genderPicker)
        view.addSubview(genderPickerToolBar)
        view.addSubview(birthdayPicker)
        view.addSubview(birthdayPickerToolBar)
        genderPicker.isHidden = true
        genderPickerToolBar.isHidden = true
        birthdayPicker.isHidden = true
        birthdayPickerToolBar.isHidden = true
       
        
        tableView.delegate = self
        tableView.dataSource = self
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
        genderPicker.frame = CGRect(x: 0, y: 700, width: view.width, height: 150)
        genderPickerToolBar.frame = CGRect(x: 0, y: 650, width: genderPicker.width, height: 50)
 
        birthdayPicker.frame = CGRect(x: 0, y: 700, width: view.width, height: 150)
        birthdayPickerToolBar.frame = CGRect(x: 0, y: 650, width: birthdayPicker.width, height: 50)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.configureModels()
        }
        
        
    }
    private func didTapGender(){
        genderPicker.isHidden = false
        genderPickerToolBar.isHidden = false
        birthdayPicker.isHidden = true
        birthdayPickerToolBar.isHidden = true
    }
    private func didTapBirthday(){
        birthdayPicker.isHidden = false
        birthdayPickerToolBar.isHidden = false
        genderPicker.isHidden = true
        genderPickerToolBar.isHidden = true
    }
    private func didTapProfile(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    @objc func cancelSexPicler(){
        genderPicker.isHidden = true
        genderPickerToolBar.isHidden = true
    }
    @objc func doneSexPicker(){
        StorageManager.shared.updateGender(gender: gender)
        genderPicker.isHidden = true
        genderPickerToolBar.isHidden = true
        configureModels()
        
    }
    @objc func cencelBirthdayPicker(){
        birthdayPicker.isHidden = true
        birthdayPickerToolBar.isHidden = true
    }
    @objc func getBirthday(){
        let formatter = DateFormatter()
        let date = birthdayPicker.date
        formatter.dateFormat = "MM/DD/YY"
        let dateStr = formatter.string(from: date)
        StorageManager.shared.updateBirthday(birthday: dateStr)
    }

    @objc func doneBirthdayPicker(){
        configureModels()
        birthdayPicker.isHidden = true
        birthdayPickerToolBar.isHidden = true
        
    }
   
    func emptyPicker(){
        birthdayPicker.isHidden = true
        birthdayPickerToolBar.isHidden = true
        genderPicker.isHidden = true
        genderPickerToolBar.isHidden = true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //profilePicture
        if indexPath.section == 0 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageTableViewCell.identifier, for: indexPath) as! ProfileImageTableViewCell
            if(profileURL != nil){
                cell.configure(with: profileURL!)
            }
            return cell
        }
        //gender,nickname,birthday
        else if indexPath.row != 0 && indexPath.row < data.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = data[(indexPath.row) - 1].title + "               " + (data[(indexPath.row) - 1].value ?? "test")
            return cell
        }
        //bio
        else if indexPath.row != 0 && indexPath.row == data.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = data[(indexPath.row) - 1].title + "       " + (data[(indexPath.row) - 1].value ?? "test")
            return cell
            
        }

        return UITableViewCell()
      
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 120
        }
        else {
            return 60
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row{
        case 0:
            didTapProfile()
        case 1:
            didTapGender()
        case 2:
            emptyPicker()
            let vc = NicknameSettingViewController()
            vc.title = "edit nickname"
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            didTapBirthday()
        case 4:
            emptyPicker()
            let vc = SignatureViewController()
            vc.title = "edit bio"
            navigationController?.pushViewController(vc, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    
        
       
    }
    
}
extension EditProfileViewController:EditTableViewCellDelegate{
    func editTableViewCell(_ cell: EditTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        return
    }
}

extension EditProfileViewController:UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
}

extension EditProfileViewController:UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return "male"
        }
        else {
            return "female"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{
            gender = "male"
            StorageManager.shared.updateGender(gender: gender)
        }
        else {
            gender = "female"
            StorageManager.shared.updateGender(gender: gender)
        }
    }
}
extension EditProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        StorageManager.shared.uploadUserProfilePicture(image: image)
        
        picker.dismiss(animated: true){ [weak self] in
            self?.configureModels()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

 
