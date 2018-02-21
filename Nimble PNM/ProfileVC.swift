//
//  ProfileVC.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class ProfileVC: BaseVC, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var constraintScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnOutletLogout: UIButton!
    @IBOutlet weak var collectionViewProfile: UICollectionView!
    @IBOutlet weak var labelHeadingProfile: UILabel!
    
    @IBOutlet weak var labelSigninName: UILabel!
    @IBOutlet weak var labelSigninEmail: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var labelConfigUrl: UILabel!
    
    var sizeGoverner :CGFloat!
    
    let Mod_Password_Change = "passwordchange"
    let Mod_Setting = "setting"
    
    let IMG_Mod_Password_Change : UIImage =  UIImage(named: "password-change")!
    let IMG_Mod_Setting : UIImage =  UIImage(named: "settings")!
    
    let SEGUEID_Mod_Password_Change : String = "segue-to-password-change"
    let SEGUEID_Mod_Setting : String = "segue-to-setting"
    
    
    let TXT_Mod_Password_Change : String = "Password Change"
    let TXT_Mod_Setting : String = "Resync"
    

    let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SyncMobileVC") as! SyncMobileVC
    
    
    var bundleData = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUIComponents()
        self.insertIndependentModules()
        self.collectionViewProfile.reloadData()

    }
    
    func configureUIComponents(){
        
        let firstName = USER_DEFAULTS.value(forKey: DEFAULTS_FIRST_NAME) as! String
        let LastName = USER_DEFAULTS.value(forKey: DEFAULTS_LAST_NAME) as! String
        let signInEmail = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String
        let versionName = USER_DEFAULTS.value(forKey: DEFAULTS_VERSION_NAME) as! String
        
        self.labelHeadingProfile.text = TXT_LBL_PROFILE_HEAD
        self.labelSigninName.text = "\(firstName) \(LastName)"
        self.labelSigninEmail.text = signInEmail
        self.labelConfigUrl.text = BASE_URL
        self.labelVersion.text = "Version \(versionName)"
        
        let cellNib = UINib(nibName: "HomeViewCollectionCell", bundle: nil)
        self.collectionViewProfile.register(cellNib, forCellWithReuseIdentifier: "customcell")
        
        resizeView(forSize: self.view.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
    }
    
    func resizeView(forSize size: CGSize){
        if size.width < size.height{
            sizeGoverner = size.width
        }else{
            sizeGoverner = size.height
        }
        
        constraintCollectionViewHeight.constant = (sizeGoverner)/2
        constraintScrollViewHeight.constant = 280 + (sizeGoverner)/2
    }
    
    func addModule(module : String){
        var dictToInsert: [String:Any] = [:]
        
        if module == Mod_Password_Change{
            dictToInsert = ["text":TXT_Mod_Password_Change,
                            "image":IMG_Mod_Password_Change,
                            "segueID":SEGUEID_Mod_Password_Change
            ]
        }
        
        if module == Mod_Setting{
            dictToInsert = ["text":TXT_Mod_Setting,
                            "image":IMG_Mod_Setting,
                            "segueID":SEGUEID_Mod_Setting
            ]
        }
        self.bundleData.add(dictToInsert)
    }
    
    func insertIndependentModules(){
        self.addModule(module: Mod_Password_Change)
        self.addModule(module: Mod_Setting)
        
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
    
    
    //MARK: UICollection View Delegates And Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bundleData.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customcell", for: indexPath) as! HomeViewCollectionCell
        let cellNo = indexPath.row
        
        
        cell.viewImageHolder.addShadow(withColor: COLOR_BORDER_GRAY_MODIFIED)
        
        let cellData = bundleData[cellNo] as! [String:Any]
        cell.imageViewItem.image = (cellData["image"] as! UIImage);
        cell.labelItem.text = cellData["text"] as? String;
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellNo = indexPath.row
        
        let cellData = bundleData[cellNo] as! [String:Any]
        let segueIdentifier = cellData["segueID"] as! String
        
        if segueIdentifier == SEGUEID_Mod_Setting{
            settingsVC.isLoadedAsSettingVC = true
            navigationController?.pushViewController(settingsVC, animated: true)
            
        }else if segueIdentifier == SEGUEID_Mod_Password_Change{
            self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = ((sizeGoverner-16) / 2);
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8;
    }
    


}
