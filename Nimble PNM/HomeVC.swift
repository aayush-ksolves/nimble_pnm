//
//  HomeVCViewController.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//


import UIKit

class HomeVC: BaseVC,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var collectionViewHome: UICollectionView!
    @IBOutlet weak var btnOutletLogout: UIButton!
    @IBOutlet weak var labelHeadingHome: UILabel!
    
    
    var bundleData = NSMutableArray()    
    
    let Mod_CM_Anlayzer = "cmanalyzer"
    let Mod_Install_CM = "installCm"
    let Mod_Upstream_Analyzer = "upstreamanalyzer"
    let Mod_Geocode = "geocode"
    let Mod_Workorder = "workorderservice"
    let Mod_Nimble_Spectra = "nimbleSpectra"
    let Mod_Profile = "profile"
    
    let IMG_Mod_CM_Anlayzer : UIImage =  UIImage(named: "cm-lookup")!
    let IMG_Mod_Install_CM : UIImage =  UIImage(named: "cm-analyzer")!
    let IMG_Mod_Upstream_Analyzer : UIImage =  UIImage(named: "up-stream")!
    let IMG_Mod_Geocode : UIImage =  UIImage(named: "geocode")!
    let IMG_Mod_Workorder : UIImage =  UIImage(named: "work-order")!
    let IMG_Mod_Nimble_Spectra : UIImage =  UIImage(named: "spectra")!
    let IMG_Mod_Profile : UIImage =  UIImage(named: "profile")!
    
    let SEGUEID_Mod_CM_Anlayzer : String = "segue-to-cm-analyzer"
    let SEGUEID_Mod_Install_CM : String = "segue-to-install-cm"
    let SEGUEID_Mod_US_Analyzer : String = "segue-to-upstream-analyzer"
    let SEGUEID_Mod_Geocode : String = "segue-to-geocode"
    let SEGUEID_Mod_Workorder : String = "segue-to-workorder"
    let SEGUEID_Mod_Nimble_Spectra : String = "segue-to-nimble-spectra"
    let SEGUEID_Mod_Profile : String = "segue-to-profile"
    
    let TXT_Mod_CM_Anlayzer : String = "CM Analyzer"
    let TXT_Mod_Install_CM : String = "Install CM"
    let TXT_Mod_Upstream_Analyzer : String = "US Analyzer"
    let TXT_Mod_Geocode : String = "Geocode"
    let TXT_Mod_Workorder : String = "Workorder"
    let TXT_Mod_Nimble_Spectra : String = "Nimble Spectra"
    let TXT_Mod_Profile : String = "Profile"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUIComponents()
        self.loadModules()
    }
    
    
    func configureUIComponents(){
        let cellNib = UINib(nibName: "HomeViewCollectionCell", bundle: nil)
        self.collectionViewHome.register(cellNib, forCellWithReuseIdentifier: "customcell")
        
        self.labelHeadingHome.text = TXT_LBL_HOME_HEAD
        
        self.btnOutletLogout.imageView?.contentMode = .scaleAspectFit
        
    }
    
    func loadModules(){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        
        let parametersDict : [String : Any] = [REQ_PARAM_USERNAME: username ,
                               REQ_PARAM_AUTH_KEY: authKey
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_HOME_CHECK_MODULES, withParameters: parametersDict, withLoaderMessage: LOADER_MSG_LOADING_MODULES, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing: responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            
            
            if statusCode == 200{
                let dataDictionary = responseDict.value(forKey: RESPONSE_PARAM_DATA)! as! NSDictionary
                
                let installCm = dataDictionary.value(forKey: RESPONSE_PARAM_INTSALL_CM) as! Bool
                let upstreamAnalyzerMonitor = dataDictionary.value(forKey: RESPONSE_PARAM_UPSTREAM_MONITOR)  as! Bool
                let upstreamAnalyzer = dataDictionary.value(forKey: RESPONSE_PARAM_UPSTREAM_ANALYZER) as! Bool
                let nimbleSpectra = dataDictionary.value(forKey: RESPONSE_PARAM_NIMBLE_SPECTRA) as! Bool
                let geocode = dataDictionary.value(forKey: RESPONSE_PARAM_GEOCODE) as! Bool
                let workorderservice = dataDictionary.value(forKey: RESPONSE_PARAM_WO_SERVICE) as! Bool
                
                if installCm{
                    self.addModule(module: self.Mod_Install_CM)
                }
                
                if upstreamAnalyzerMonitor{
                    self.addModule(module: self.Mod_CM_Anlayzer)
                }
                
                if upstreamAnalyzer{
                    self.addModule(module: self.Mod_Upstream_Analyzer)
                }
                
                if nimbleSpectra{
                    self.addModule(module: self.Mod_Nimble_Spectra)
                }
                
                if geocode{
                    self.addModule(module: self.Mod_Geocode)
                }
                
                if workorderservice{
                    self.addModule(module: self.Mod_Workorder)
                }
                
                self.insertIndependentModules()
                
                self.collectionViewHome.reloadData()
                
                
            }else if statusCode == 401{
                //Auth Key Expired
                self.performLogoutAsSessionExpiredDetected()
                
            }else if statusCode == 404{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
    
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })

    }
    
    
    func insertIndependentModules(){
        self.addModule(module: Mod_Profile)
    }
    
    
    func addModule(module : String){
        var dictToInsert: [String:Any] = [:]
        
        if module == Mod_CM_Anlayzer{
            dictToInsert = ["text":TXT_Mod_CM_Anlayzer,
                            "image":IMG_Mod_CM_Anlayzer,
                            "segueID":SEGUEID_Mod_CM_Anlayzer
            ]
        }
        
        if module == Mod_Install_CM{
            dictToInsert = ["text":TXT_Mod_Install_CM,
                            "image":IMG_Mod_Install_CM,
                            "segueID":SEGUEID_Mod_Install_CM
            ]
        }
        
        if module == Mod_Upstream_Analyzer{
            dictToInsert = ["text":TXT_Mod_Upstream_Analyzer,
                            "image":IMG_Mod_Upstream_Analyzer,
                            "segueID":SEGUEID_Mod_US_Analyzer
            ]
        }
        
        if module == Mod_Geocode{
            dictToInsert = ["text":TXT_Mod_Geocode,
                            "image":IMG_Mod_Geocode,
                            "segueID":SEGUEID_Mod_Geocode
            ]
        }
        
        if module == Mod_Workorder{
            dictToInsert = ["text":TXT_Mod_Workorder,
                            "image":IMG_Mod_Workorder,
                            "segueID":SEGUEID_Mod_Workorder
            ]
        }
        
        if module == Mod_Nimble_Spectra{
            dictToInsert = ["text":TXT_Mod_Nimble_Spectra,
                            "image":IMG_Mod_Nimble_Spectra,
                            "segueID":SEGUEID_Mod_Nimble_Spectra
            ]
        }
        
        if module == Mod_Profile{
            dictToInsert = ["text":TXT_Mod_Profile,
                            "image":IMG_Mod_Profile,
                            "segueID":SEGUEID_Mod_Profile
            ]
        }
        
        self.bundleData.add(dictToInsert)
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
        
        if segueIdentifier == SEGUEID_Mod_Profile{
            self.tabBarController?.selectedIndex = TAB_INDEX_PROFILE
            
        }else if segueIdentifier == SEGUEID_Mod_US_Analyzer{
            self.tabBarController?.selectedIndex = TAB_INDEX_US_ANANLYZER
            
        }else if segueIdentifier == SEGUEID_Mod_Install_CM{
            self.tabBarController?.selectedIndex = TAB_INDEX_INSTALL_CM
            
        }else{
            self.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
        
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var sizeGoverner :CGFloat;
        
        if SCREEN_SIZE.width < SCREEN_SIZE.height{
            sizeGoverner = SCREEN_SIZE.width
        }else{
            sizeGoverner = SCREEN_SIZE.height
        }
        
        let cellWidth = ((sizeGoverner-16) / 3);
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
