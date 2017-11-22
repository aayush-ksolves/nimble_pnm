//
//  WorkOrderModemDetails.swift
//  Nimble PNM
//
//  Created by KSolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit


class WorkOrderModemDetails : BaseVC, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    @IBOutlet weak var tableViewWODetails: UITableView!
    
    @IBOutlet weak var buttonAddComments: UIButton!
    @IBOutlet weak var textViewAddComments: UITextView!
    @IBOutlet weak var viewAddComments: UIView!
    var exposedOrderID = ""
    let imagePicker = UIImagePickerController()
    var bundleWorkOrderDetails = WorkOrderDetailsDS()
    let footerView = UIView()
    var numberOfSections = 2
    var isLocked = false
    var shouldReloadView = true
    
    let imageLocked: UIImage = #imageLiteral(resourceName: "lock")
    let imageUnlocked: UIImage = #imageLiteral(resourceName: "unlock")
    
    let usertype = USER_DEFAULTS.value(forKey: DEFAULTS_USER_TYPE) as! String
    
    var tableFooterViewButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUIComponents()
    }
    
    func getTechnicianFeedbackText(feedBackArray: NSArray) -> String {
        
        var stringTechnicianFeedback = ""
        stringTechnicianFeedback.append("\n")
        
        for stringFB in feedBackArray {
            if String(describing: stringFB) != ""{
                stringTechnicianFeedback.append(String(describing: stringFB))
                stringTechnicianFeedback.append("\n")
            }
        }
        
        return stringTechnicianFeedback
    }
    
    func configureUIComponents() {
        
        tableViewWODetails.estimatedRowHeight = 150
        tableViewWODetails.estimatedSectionHeaderHeight = 50
        tableViewWODetails.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableViewWODetails.rowHeight = UITableViewAutomaticDimension
        
        tableViewWODetails.backgroundColor = COLOR_WHITE_AS_GREY
        footerView.backgroundColor = COLOR_NONE
        
        tableViewWODetails.register(UINib(nibName: "WOModemDetailsFirstCell", bundle: nil), forCellReuseIdentifier: "WOModemDetailsFirstCell")
        tableViewWODetails.register(UINib(nibName: "WOModemDetailsSecondCell", bundle: nil), forCellReuseIdentifier: "WOModemDetailsSecondCell")
        tableViewWODetails.register(UINib(nibName: "WODetailsAttachmentCell", bundle: nil), forCellReuseIdentifier: "WODetailsAttachmentCell")
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(viewCommentsTapped))
        viewAddComments.addGestureRecognizer(tapGesture)
        
        self.buttonAddComments.addTarget(self, action: #selector(buttonSendCommentsPressed), for: .touchUpInside)
        
        imagePicker.delegate = self
        textViewAddComments.delegate = self
        textViewAddComments.addBorder(withColor: UIColor.darkGray, withWidth: 1)
        showViewAddComment(shouldShow: false)
    }
    
    @objc func viewCommentsTapped(){
        showViewAddComment(shouldShow: false)
    }
    
    func setTableFooterButton() {
        
        tableFooterViewButton = UIButton(frame: CGRect(x: 0, y: 0, width: tableViewWODetails.frame.size.width, height: 40))
        tableFooterViewButton.setTitle("Mark As Fixed", for: .normal)
        tableFooterViewButton.setTitleColor(UIColor.white, for: .normal)
        tableFooterViewButton.backgroundColor = UIColor.green
        tableFooterViewButton.addTarget(self, action: #selector(markAsFixedPressed), for: .touchUpInside)
        
        tableViewWODetails.tableFooterView = tableFooterViewButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if shouldReloadView {
            loadWorkOrderDetails()
        }else{
            shouldReloadView = true
        }
        
    }
    
    @objc func markAsFixedPressed() {
        
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_CONFIRM, message: ALERT_MSG_WO_MARK_FIXED, buttonTitle1: ALERT_BUTTON_NO, buttonTitle2: ALERT_BUTTON_YES, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: {
            action in
            //Do Nothing
        }, completionHandler2: {
            action in
            
            self.markedWorkOrderFixed()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func markedWorkOrderFixed() {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_ORDER_ID: bundleWorkOrderDetails.orderId,
                              REQ_PARAM_STATUS: "fixed"
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_UPDATE, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_WO_UPDATE, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                self.loadWorkOrderDetails()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else if section == 1 {
            return 2
        }else if section == 2 {
            return 1
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = Bundle.main.loadNibNamed("WOModemDetailsHeaderTop", owner: self, options: nil)?[0] as! WOModemDetailsHeaderTop
            headerView.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
        
            headerView.buttonReassign.addTarget(self, action: #selector(buttonReassignPressed), for: .touchUpInside)
            headerView.buttonUnlock.addTarget(self, action: #selector(buttonUnlockPressed), for: .touchUpInside)
            
            headerView.buttonReassign.isEnabled = !isLocked
            
            if isLocked {
                headerView.buttonUnlock.setImage(#imageLiteral(resourceName: "lock"), for: .normal)
                headerView.buttonReassign.backgroundColor = UIColor.gray
            }else {
                headerView.buttonUnlock.setImage(#imageLiteral(resourceName: "unlock"), for: .normal)
                headerView.buttonReassign.backgroundColor = COLOR_BLUE_IONIC_V1
            }
            
            headerView.labelOrderId.text = "Order Id \n\(bundleWorkOrderDetails.orderId)"
            
            return headerView
        } else if section == 1 {
            let headerView = Bundle.main.loadNibNamed("WOHeaderFeedback", owner: self, options: nil)?[0] as! WOHeaderFeedback
            
            return headerView
        } else {
            
            // Never Occur
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNo = indexPath.row
        let sectionNo = indexPath.section
        
        if sectionNo == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WOModemDetailsFirstCell") as! WOModemDetailsFirstCell
            
            if bundleWorkOrderDetails.type == TYPE_MODEM {
                cell.labelType.text = "Modem"
                cell.labelMacAddressHead.text = "MAC Address"
                cell.labelMACAddress.text = bundleWorkOrderDetails.macAddress
            }else{
                cell.labelType.text = "Node"
                cell.labelMacAddressHead.text = "Interface"
                cell.labelMACAddress.text = bundleWorkOrderDetails.interface
            }
            
            cell.labelAssisgnedBy.text = bundleWorkOrderDetails.assignedBy
            cell.labelAssignedTo.text = bundleWorkOrderDetails.assignedTo
            cell.labelAssignedDate.text = bundleWorkOrderDetails.assignedDate
            cell.labelCustomerName.text = bundleWorkOrderDetails.customerName
            cell.labelAddress.text = bundleWorkOrderDetails.address
            cell.labelContact.text = bundleWorkOrderDetails.contact
            cell.labelStatus.text = bundleWorkOrderDetails.status.uppercased()
            
            return cell;
        }else if sectionNo == 1 {
            
            if rowNo == 0 {

                let cell = tableView.dequeueReusableCell(withIdentifier: "WOModemDetailsSecondCell") as! WOModemDetailsSecondCell
                
                if self.bundleWorkOrderDetails.feedback.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    cell.labelComments.text = "\nNo Comments \n"
                    cell.labelComments.textColor = UIColor.lightGray
                    cell.labelComments.textAlignment = .center
                }else{
                    cell.labelComments.text = self.bundleWorkOrderDetails.feedback
                    cell.labelComments.textColor = UIColor.darkGray
                    cell.labelComments.textAlignment = .left
                }
                
                if usertype == "1" {
                    cell.buttonComment.isHidden = true
                }else{
                    cell.buttonComment.isHidden = false
                }
                
                cell.buttonComment.addTarget(self, action: #selector(buttonAddCommentPressed), for: .touchUpInside)
                
                return cell
                
            }else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "WODetailsAttachmentCell") as! WODetailsAttachmentCell
                
                cell.labelNoAttachments.isHidden = (bundleWorkOrderDetails.arrayAttachment.count > 0)
                
                cell.collectionView.register(UINib(nibName: "WODetailsImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WODetailsImageCollectionViewCell")
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.reloadData()
                
                if usertype == "1" {
                    cell.buttonAddImage.isHidden = true
                }else{
                    cell.buttonAddImage.isHidden = false
                }
                
                cell.buttonAddImage.addTarget(self, action: #selector(buttonAddImagePressed), for: .touchUpInside)
                
                return cell
            }
            
        }else {
            
            // Never Occur
            return UITableViewCell()
        }
        
    }
    
    // Collection View Data Source And Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bundleWorkOrderDetails.arrayAttachment.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 70, height: 70)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Creating Cell")
        
        let cellNo = indexPath.row
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WODetailsImageCollectionViewCell", for: indexPath)  as! WODetailsImageCollectionViewCell
        
        cell.imageViewPhoto.af_setImage(withURL: URL(string: self.bundleWorkOrderDetails.arrayAttachment.object(at: cellNo) as! String)!)
        cell.buttonCross.tag = cellNo
        cell.buttonCross.addTarget(self, action: #selector(buttonCrossPressed(_:)), for: .touchUpInside)
        
        if bundleWorkOrderDetails.status == TYPE_FIXED || bundleWorkOrderDetails.status == TYPE_CLOSED{
            cell.buttonCross.isHidden = true
        }else{
            cell.buttonCross.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.shouldReloadView = false
        let cellNo = indexPath.row
        let presentationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewerVC") as! ImageViewerVC
        presentationController.exposedImageURL = self.bundleWorkOrderDetails.arrayAttachment.object(at: cellNo) as! String
        self.navigationController?.pushViewController(presentationController, animated: true)
        
    }
    
    @objc func buttonCrossPressed(_ sender: UIButton){
        
        let tag = sender.tag
        
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_CONFIRM, message: ALERT_MSG_WO_DELETE_IMAGE, buttonTitle1: ALERT_BUTTON_NO, buttonTitle2: ALERT_BUTTON_YES, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: {
            action in
            //Do Nothing
        }, completionHandler2: {
            action in
            
            self.deleteWOImage(forSection: tag)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func buttonAddCommentPressed(){
        showViewAddComment(shouldShow: true)
    }
    
    func showViewAddComment(shouldShow: Bool){
        if shouldShow {
            self.viewAddComments.isHidden = false
            self.textViewAddComments.text = ""
            self.textViewAddComments.becomeFirstResponder()
        }else{
            self.textViewAddComments.resignFirstResponder()
            self.viewAddComments.isHidden = true
        }
    }
    
    @objc func buttonSendCommentsPressed(){
        
        self.textViewAddComments.resignFirstResponder()
        let textComment = self.textViewAddComments.text!
        
        if textComment == "" {
            
            let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_WO_ENTER_COMMENT, buttonTitle: ALERT_BUTTON_OK, completionHandler: {
                action in
                self.textViewAddComments.becomeFirstResponder()
            })
            self.present(alert, animated: true, completion: nil)
            
        }else{
            self.sendCommentOnServer(textComment: textComment)
        }
    }
    
    func sendCommentOnServer(textComment: String) {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_STATUS: bundleWorkOrderDetails.status,
                              REQ_PARAM_ORDER_ID: bundleWorkOrderDetails.orderId,
                              RESPONSE_PARAM_FEEDBACK: textComment
                     ]
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_UPDATE, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_WO_UPDATE, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                self.showViewAddComment(shouldShow: false)
                self.loadWorkOrderDetails()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
        
    }
    
    @objc func buttonAddImagePressed(){
        if bundleWorkOrderDetails.arrayAttachment.count < 5 {
            showSelectImageOption()
        }else{
            self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: ALERT_MSG_WO_ADD_ATTACHMENTS, withButtonTitle: ALERT_BUTTON_OK)
        }
    }
    
    func showSelectImageOption(){
        let actionSheet = UtilityHelper.makeActionSheetWithThreeActions(withTitle: AS_PHOTO_TITLE, withMessage: AS_PHOTO_MSG, withAction1Name: AS_PHOTO_OPTION1, withAction1Handler: {
            
            self.shouldReloadView = false
            self.setImagePickerToChooseFromLibrary()
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }, withAction2Name: AS_PHOTO_OPTION2, withAction2Handler: {
            
            self.shouldReloadView = false
            self.setImagePickerToChooseFromCamera()
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }, withAction3Name: AS_PHOTO_CANCEL, withAction3Handler: {
            self.shouldReloadView = true
            
        })
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func setImagePickerToChooseFromLibrary(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }
    
    func setImagePickerToChooseFromCamera(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: false, completion: nil)
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            let chosenImage = (info[UIImagePickerControllerOriginalImage] as! UIImage)
            let normalizedImage = UtilityHelper.getUpImage(inputImage: chosenImage)
            self.uploadAttachmentOnServer(image: normalizedImage)
            
        }else{
            print("Something went wrong")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    func uploadAttachmentOnServer(image: UIImage){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_ORDER_ID: bundleWorkOrderDetails.orderId,
        ];
        
        let imageArray = NSMutableArray()
        let tempDic : NSDictionary = [PARAM_NAME: "image", PARAM_IMAGE: image]
        imageArray.add(tempDic)
        
        self.networkManager.uploadImageWithData(url: SERVICE_URL_WO_UPLOAD_ATTACHMENT, withParameters: dictParameters, bundleImagesArray: imageArray, withLoaderMessage: LOADER_MSG_WO_UPDATE, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                self.loadWorkOrderDetails()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        }, failureCompletionHandler:{
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
        
    }
    
    func deleteWOImage(forSection: Int){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        let imageUrl = self.bundleWorkOrderDetails.arrayAttachment.object(at: forSection) as! String
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_IMAGE_URL: imageUrl,
                              REQ_PARAM_ORDER_ID: bundleWorkOrderDetails.orderId,
        ]
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_DELETE_ATTACHMENT, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_WO_UPDATE, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200 {
                self.loadWorkOrderDetails()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
        
    }
    
    
    @objc func buttonReassignPressed(){
        
        self.performSegue(withIdentifier: "segue-to-assign-technician", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-assign-technician"{
            
            let destinationController = segue.destination as! AssignTechicianVC
            destinationController.exposedOrderId = bundleWorkOrderDetails.orderId
            destinationController.exposedCMTESID = bundleWorkOrderDetails.cmtsId
        }
    }
    
    @objc func buttonUnlockPressed() {
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_CONFIRM, message: getAlertMsgLockUnlock(), buttonTitle1: ALERT_BUTTON_NO, buttonTitle2: ALERT_BUTTON_YES, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: {
            action in
            //Do Nothing
        }, completionHandler2: {
            action in
            
            self.performActionOnLockUnlock()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAlertMsgLockUnlock() -> String {
        
        if isLocked {
            return ALERT_MSG_WO_UNLOCK
        }else {
            return ALERT_MSG_WO_LOCK
        }
    }
    
    func getLockUnlockStatus() -> String{
        
        if isLocked {
            return "0"
        }else {
            return "1"
        }
    }
    
    func performActionOnLockUnlock() {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_ORDER_ID: bundleWorkOrderDetails.orderId,
                              REQ_PARAM_IS_LOCKED: getLockUnlockStatus()
                              ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_LOCK_UNLOCK, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_LOCKING_WO, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                self.loadWorkOrderDetails()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
        
    }
    
    func loadWorkOrderDetails(){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_FILTER : [
                                REQ_PARAM_ID: exposedOrderID
                                ]
        ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_LIST, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_WO_DETAILS, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
            
            if statusCode == 200{
                for eachRecord in dataArray{
                    
                    self.bundleWorkOrderDetails.status = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_STATUS)!)
                    self.bundleWorkOrderDetails.type = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TYPE)!)
                    self.bundleWorkOrderDetails.orderId = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ID)!).checkNullString()
                    self.bundleWorkOrderDetails.assignedTo = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ASSIGNED_TO)!).checkNullString()
                    
                    if let address = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS){
                        self.bundleWorkOrderDetails.address = String(describing: address).checkNullString()
                    }
                    
                    if let contact = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_PHONE_NUMBER){
                        self.bundleWorkOrderDetails.contact = String(describing: contact).checkNullString()
                    }
                    
                    if let custName = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CUST_NAME){
                        self.bundleWorkOrderDetails.customerName = String(describing: custName).checkNullString()
                    }
                    
                    if let macAddress = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_MAC_ADDRESS){
                        self.bundleWorkOrderDetails.macAddress = String(describing: macAddress).checkNullString()
                    }
                    
                    if let interface = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_INTERFACE_NAME){
                        self.bundleWorkOrderDetails.interface = String(describing: interface).checkNullString()
                    }
                    
                    self.bundleWorkOrderDetails.assignedDate = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CREATION_DATE)!).checkNullString()
                    self.bundleWorkOrderDetails.assignedBy = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ASSIGNED_BY)!).checkNullString()
                    self.bundleWorkOrderDetails.cmtsId = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_WO_CMTS_ID)!).checkNullString()
                    self.bundleWorkOrderDetails.isLocked = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_IS_LOCKED)!)
                    self.bundleWorkOrderDetails.feedback = self.getTechnicianFeedbackText(feedBackArray: (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TECHNICIAN_FEEDBACK)! as! NSArray)
                    self.bundleWorkOrderDetails.arrayAttachment = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_PHOTOS)! as! NSArray
                    
                    if self.bundleWorkOrderDetails.isLocked == "1" {
                        self.isLocked = true
                    } else {
                        self.isLocked = false
                    }
                    
                    if self.bundleWorkOrderDetails.status == TYPE_IN_PROGRESS || self.bundleWorkOrderDetails.status == TYPE_IN_PROGRESS.uppercased() {
                        self.setTableFooterButton()
                    }
                }
                
                self.tableViewWODetails.reloadData()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
    
}


struct WorkOrderDetailsDS{
    var orderId : String = "-"
    var type : String = "-"
    var macAddress : String = "-"
    var assignedBy : String = "-"
    var assignedTo : String = "-"
    var assignedDate : String = "-"
    var customerName : String = "-"
    var address : String = "-"
    var contact : String = "-"
    var status : String = "-"
    var cmtsId : String = "-"
    var feedback: String = "-"
    var arrayAttachment = NSArray()
    var isLocked = "0"
    var interface = "-"
}


