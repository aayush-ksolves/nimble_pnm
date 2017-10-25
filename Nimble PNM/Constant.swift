//
//  Constant.swift
//  Nimble PNM
//
//  Created by ksolves on 13/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import Foundation
import UIKit


let APP_NAME = "Nimble PNM"


//Utility Definitions
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
let USER_DEFAULTS = UserDefaults.standard
let DEVICE = UIDevice.current
let SCREEN_SIZE = UIScreen.main.bounds.size
let SEPARATOR:String = "=SEPARATOR="



let CORNER_RADIUS_STANDARD: CGFloat = 8.0;



//COLOR DEFINITIONS
let COLOR_BLUE_IONIC_V2 = UIColor(red: 72/255, green: 138/255, blue: 255/255, alpha: 1.0)
let COLOR_BLUE_IONIC_V1 = UIColor(red: 56/255, green: 126/255, blue: 245/255, alpha: 1.0)

let COLOR_SCAN_REGION_BORDER = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)

let COLOR_BORDER_GRAY_MODIFIED = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)

let COLOR_WHITE_AS_GREY = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
let COLOR_WHITE_AS_GREY_LIGHT = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)

let COLOR_NONE = UIColor.clear




let SIZE_FONT_SMALL : CGFloat = 12
let SIZE_FONT_MEDIUM : CGFloat = 14
let SIZE_FONT_LARGE : CGFloat = 16



//User Defaults Constants
let DEFAULTS_SETTINGS_URL = "DEFAULTS_SETTINGS_URL"
let DEFAULTS_IS_LOGGED_IN = "DEFAULTS_IS_LOGGED_IN"

let DEFAULTS_AUTH_KEY = "DEFAULTS_AUTH_KEY"
let DEFAULTS_ID = "DEFAULTS_ID"
let DEFAULTS_FIRST_NAME = "DEFAULTS_FIRST_NAME"
let DEFAULTS_LAST_NAME = "DEFAULTS_LAST_NAME"
let DEFAULTS_EMAIL_ID = "DEFAULTS_EMAIL_ID"
let DEFAULTS_USER_TYPE = "DEFAULTS_USER_TYPE"

let DEFAULTS_AUTO_LOGIN_USERNAME = "DEFAULTS_AUTO_LOGIN_USERNAME"
let DEFAULTS_AUTO_LOGIN_PASSWORD = "DEFAULTS_AUTO_LOGIN_PASSWORD"



//WEB Service URLS
var BASE_URL :String = "http://10.0.0.22/testing/master2/index.php"


let SERVICE_URL_LOGIN = "/pnmservice/login";
let SERVICE_URL_LOGOUT = "/pnmservice/logout";

let SERVICE_URL_HOME_CHECK_MODULES = "/pnmservice/checkModules";
let SERVICE_URL_PROFILE_CHANGE_PASSWORD = "/pnmservice/changePassword"

let SERVICE_URL_WO_LIST = "/workorderservice/getWorkOrderList"
let SERVICE_URL_NEARBY_MODEMS = "/pnmservice/modemsByLocation"


let SERVICE_URL_WO_TECHNICIAN_LIST = "/workorderservice/getTechnicianList"
let SERVICE_URL_WO_REASSIGN = "/workorderservice/reAssignWorkOrder"
let SERVICE_URL_WO_LOCK_UNLOCK = "/workorderservice/lockUnlockWorkOrders"

let SERVICE_URL_INSTALL_LOAD_FAILED = "/pnmservice/getFailedModem"
let SERVICE_URL_INSTALL_COMPLETE_FAILED = "/pnmservice/completeFailedModem"
let SERVICE_URL_INSTALL_GET_MODEM_STATUS = "/pnmservice/getModemInstallStatus"
let SERVICE_URL_INSTALL_CABLE_MODEM = "/pnmservice/installCableModem"

let SERVICE_URL_INSTALL_GET_DS_DATA = "/pnmservice/getModemDownStream"
let SERVICE_URL_GEOCODE_SAVE = "/pnmservice/saveGeocode"

let SERVICE_URL_WO_MARK_FIXED = "/workorderservice/updateWorkOrder"
let SERVICE_URL_US_ANALYZER_CMTS_LIST = "/pnmservice/listCmts"
let SERVICE_URL_US_ANALYZER_CMTS_PORT = "/pnmservice/getCmtsPort"

let SERVICE_URL_CM_ANALYZER_GET_MODEM_DATA = "/pnmservice/getModemData"
let SERVICE_URL_CM_ANALYZER_RE_SCAN_MODEM = "/pnmservice/reScanModem"
let SERVICE_URL_CM_ANALYZER_GET_DS_DATA = "/pnmservice/getModemDownStream"


let SERVICE_URL_NIMBLE_SPECTRA_IMPAIR_COUNT = "/nimbleSpectra/nimbleSpectraService/getCmtsListWithImpairmentCount";


//Tab Index Governers
let TAB_INDEX_HOME:Int = 0
let TAB_INDEX_INSTALL_CM:Int = 1
let TAB_INDEX_US_ANANLYZER:Int = 2
let TAB_INDEX_PROFILE:Int = 3



//Loader Constants
let LOADER_MSG_LOGIN = "Logging In ..."
let LOADER_MSG_ANOTHER_LOGOUT = "Logging Out ..."
let LOADER_MSG_LOGOUT = "Logging Out ..."
let LOADER_MSG_LOADING_MODULES = "Loading Modules ..."
let LOADER_MSG_FETCH_WO = "Fetching Work Orders ..."
let LOADER_MSG_FETCH_WO_DETAILS = "Fetching Work Order Details ..."
let LOADER_MSG_FETCH_NB_MODEMS = "Fetching Nearby Modems ..."
let LOADER_MSG_PASSWORD_CHANGE = "Requesting Password Change ..."
let LOADER_MSG_FAILED_MODEMS = "Loading Failed Modems ..."
let LOADER_MSG_REFRESH_FAILED_MODEMS = "Updating Failed Modems ..."
let LOADER_MSG_COMPLETE_FAILED_MODEMS = "Completing Failed Modem ..."
let LOADER_MSG_GETTING_MODEM_STATUS = "Getting Modem Status ..."
let LOADER_MSG_GEOCODE_SAVING = "Saving Geocode data ..."

let LOADER_MSG_INSTALL_MODEMS = "Installing Modem ..."

let LOADER_MSG_GETTING_DS_DATA = "Fetching Downstream Data ..."


let LOADER_MSG_FETCH_TECH_LIST = "Fetching Technician List ..."
let LOADER_MSG_REASSIGN_WO = "Re-assigning Work Order ..."
let LOADER_MSG_LOCKING_WO = "Locking Work Order ..."
let LOADER_MSG_US_CMTS_LIST = "Loading CMTS List ..."
let LOADER_MSG_US_PORT_LIST = "Loading Upstream Ports ..."


let LOADER_MSG_CM_ANALYZER_GET_MODEM_DATA = "Getting Modem Data ..."
let LOADER_MSG_CM_ANALYZER_RESCAN_MODEM = "Rescanning Modem ..."
let LOADER_MSG_CM_ANALYZER_LOAD_DS_DATA = "Loading Downstream Data ..."


let LOADER_MSG_NS_IMPAIR_COUNT = "Loading Impairment Data ..."


let LOADER_MSG_UPDATE_MODEM_LOCATION = "Updating Modem Location ..."

let LOADER_MSG_WO_MARKING_FIXED = "Marking As Fixed ..."

//MARK: Alert Definitions
//Alert Titles
let ALERT_TITLE_APP_NAME = APP_NAME
let ALERT_TITLE_INSTALL_CM_HELP = "Install New CM Help"


//Alert BarCode Scanner
let ALERT_MSG_SCAN_CAMERA_PERM_NA = "App does not have permission to access the camera."
let ALERT_MSG_SCAN_UNABLE_START = "Unable to start scanning. Please try again."

//Alerts Login Screen
let ALERT_MSG_LOGIN_BLANK_USERNAME = "Username can not be blank."
let ALERT_MSG_LOGIN_BLANK_PASSWORD = "Password can not be blank."

//US Analyzer Alerts
let ALERT_MSG_US_ANALYZER_BLANK_CMTS = "Please select a CMTS"
let ALERT_MSG_US_ANALYZER_BLANK_UPSTREAM = "Please select a Upstream Port"


let ALERT_MSG_LOGOUT_CONFIRM = "Are you sure you want to logout ?"

let ALERT_MSG_SESSION_EXPIRED = "This session has been expired. Please login."



//Install New CM Help
let ALERT_MSG_INSTALL_COMPLETE_MODEM = "Complete: means if for some unknown reason the modem is not getting installed successfully after multiple attempts, then mark the modem as complete install and it will be removed from the list."

let ALERT_MSG_INSTALL_BLANK_MAC = "Mac Address can not be blank."
let ALERT_MSG_INSTALL_VALID_MAC = "Please enter a valid mac address."

let ALERT_MSG_CM_ANALYZER_BLANK_MAC = "Mac Address can not be blank."
let ALERT_MSG_CM_ANALYZER_VALID_MAC = "Please enter a valid mac address."



// Alert Work Order Screen

let ALERT_TITLE_CONFIRM = "Confirm"
let ALERT_MSG_WO_REASSIGN = "Are you sure you want to re-assign this work order?"
let ALERT_MSG_WO_LOCK = "Are you sure you want to lock this work order?"
let ALERT_MSG_WO_UNLOCK = "Are you sure you want to unlock this work order?"



//Alerts Change Password Screen
let ALERT_MSG_CP_BLANK_CURRENT_PASSWORD = "Current Password can not be blank."
let ALERT_MSG_CP_BLANK_NEW_PASSWORD = "New Password can not be blank."
let ALERT_MSG_CP_BLANK_CONFIRM_PASSWORD = "Confirm Password can not be blank."
let ALERT_MSG_CP_NO_MATCH_PASSWORD = "New Password and Confirm Password does not match."
let ALERT_MSG_CP_PASSWORD_LENGTH = "Minimum length of password should be 6 characters."


let ALERT_MSG_UPDATE_MODEM_LOCATION = "Are you sure to change the location of modem ?"


let ALERT_MSG_INSTALL_CM_SUCCESS = "Cable modem installed successfully."
let ALERT_MSG_COMPLETE_MODEM_CONFIRM = "Are you sure you want to complete install this Modem ?"
let ALERT_MSG_COMPLETE_SUCCESS = "Modem unable to be successfully installed, so marked as complete. Supervisor will be notified."
let ALERT_MSG_COMPLETE_SUCCESS_BUT_FAILED = "Modem installed but some test cases are failed."

let ALERT_MSG_WO_MARK_FIXED = "Are you sure to mark this work order as fixed ?"

//For Geocode Screen
let ALERT_MSG_GEOCODE_ENTER_VALID_MAC = "Please enter a valid mac address"


//Alert Button Names
let ALERT_BUTTON_OK = "OK"
let ALERT_BUTTON_SHOW_DETAIL = "Show Detail"
let ALERT_BUTTON_GEOCODE = "Geocode"
let ALERT_BUTTON_CANCEL = "Cancel"
let ALERT_BUTTON_LOGOUT = "Logout"
let ALERT_BUTTON_YES = "YES"
let ALERT_BUTTON_NO = "NO"

// Image Constants Used in the code
let IMAGE_TORCH_OFF = #imageLiteral(resourceName: "flash_white");
let IMAGE_TORCH_ON = #imageLiteral(resourceName: "flash_golden");



//Constants For Respective Screen



//SYNC Mobile Screen
let TXT_LBL_INSTRUCTION_SCAN_FROM_WHERE = "Login to PNM web application and go to Help -> Sync Mobile menu to configure your mobile app with that PNM Web application"
let TXT_BTN_SCAN_CODE = "Scan QR/Barcode"
let TXT_LBL_PROFILE_HEAD = "Profile"
let TXT_LBL_HOME_HEAD = "Welcome to Proactive Network Maintenance"
let TXT_LBL_CHANGE_PASS_HEAD = "Change Password"
let TXT_LBL_WO_LIST_HEAD = "Work Order List"
let TXT_LBL_CABLE_MODEL_LOOK_UP_HEAD = "Cable Modem Look Up"
let TXT_LBL_GEOCODING_HEAD = "Geocoding"
let TXT_LBL_US_ANALAYZER_HEAD = "Nimble US Analyzer"
let TXT_LBL_CM_INSTALLER_HEAD = "Nimble CM Installer"
let TXT_LBL_CM_ANALYZER_HEAD = "CM Analyzer"



//MARK: ERROR MESSAGES
let ERROR_NORMAL = "Error"
let ERROR_UNKNOWN = "Some error occured. Please try again later."


let ERROR_TITLE_NO_INTERNET = "No Internet Connection"
let ERROR_MSG_NO_INTERNET = "Please connect to the internet."
let ERROR_TITLE_TECHNICAL_ERROR = APP_NAME
let ERROR_MSG_TECHNICAL_ERROR = "There is some technical error. Please try again later."



//SERVICE REQUEST PARAMeters
let REQ_PARAM_USERNAME = "username"
let REQ_PARAM_PASSWORD = "password"


let REQ_PARAM_USER_ID = "user_id"
let REQ_PARAM_LOGOUT_KEY = "logout_key"
let REQ_PARAM_DO_LOGOUT = "do_logout"

let REQ_PARAM_AUTH_KEY = "auth_key"


//CP SCREEN
let REQ_PARAM_CURRENT_PASS = "current_pass"
let REQ_PARAM_NEW_PASS = "new_pass"

let REQ_PARAM_MAC_ADDRESS = "mac_address"
let REQ_PARAM_CMTSID = "cmtsID"
let REQ_PARAM_PURPOSE = "purpose"

let REQ_PARAM_GEO_FIRST_NAME = "first_name"
let REQ_PARAM_GEO_LAST_NAME = "last_name"
let REQ_PARAM_GEO_ACCOUNT = "account_number"
let REQ_PARAM_GEO_ADDRESS = "address"
let REQ_PARAM_GEO_CITY = "city"
let REQ_PARAM_GEO_STATE = "state"
let REQ_PARAM_GEO_ZIP = "zipcode"
let REQ_PARAM_GEO_COUNTRY = "country"
let REQ_PARAM_GEO_PHONE = "phone_number"
let REQ_PARAM_GEO_NODE = "node_name"
let REQ_PARAM_GEO_LNG = "latitude"
let REQ_PARAM_GEO_LAT = "longitude"

let REQ_PARAM_ORDER_ID = "order_id"
let REQ_PARAM_REASSIGN_TO = "re_assigned_to"
let REQ_PARAM_REASSIGN_BY = "re_assigned_by"
let REQ_PARAM_IS_LOCKED = "is_locked"
let REQ_PARAM_LATITUDE = "latitude"
let REQ_PARAM_LONGITUDE = "longitude"
let REQ_PARAM_RADIUS = "radius"

let REQ_PARAM_ID = "id"
let REQ_PARAM_FILTER = "filter"


let REQ_PARAM_STATUS = "status"

//SERVICE RESPONSE PARAMETERS
let RESPONSE_PARAM_STATUS_CODE = "status_code"
let RESPONSE_PARAM_STATUS_MSG = "status_msg"
let RESPONSE_PARAM_DATA = "data"
let RESPONSE_PARAM_MODEM_DATA = "modem_data"
let RESPONSE_PARAM_UPSTREAM = "upstreams"
let RESPONSE_PARAM_INTERFACE_NAME = "interface_name"

let RESPONSE_PARAM_COMMON = "common"
let RESPONSE_PARAM_USER_ID = "user_id"
let RESPONSE_PARAM_LOGOUT_KEY = "logout_key"
let RESPONSE_PARAM_DO_LOGOUT = "do_logout"
let RESPONSE_PARAM_LOGOUT_URL = "logout_URL"

let RESPONSE_PARAM_FREQUENCIES = "frequencies"
let RESPONSE_PARAM_FREQ = "freq"
let RESPONSE_PARAM_MTC = "MTC"
let RESPONSE_PARAM_MR_LVL = "MRLevel"
let RESPONSE_PARAM_DELAY = "Delay"
let RESPONSE_PARAM_TDR = "TDR"
let RESPONSE_PARAM_FAR_TDR = "FarTDR"

let RESPONSE_PARAM_AUTH_KEY = "auth_key"
let RESPONSE_PARAM_EMAIL_ID = "email_id"
let RESPONSE_PARAM_FIRST_NAME = "first_name"
let RESPONSE_PARAM_ID = "id"

let RESPONSE_PARAM_US_CMTS_ID = "id"
let RESPONSE_PARAM_US_CMTS_NAME = "cmtsName"


let RESPONSE_PARAM_TEST_PASSED_DN = "testPassedDn"
let RESPONSE_PARAM_TEST_PASSED = "testPassed"
let RESPONSE_PARAM_BC = "birth_certificate"
let RESPONSE_PARAM_BW = "bw"

let RESPONSE_PARAM_LAST_NAME = "last_name"
let RESPONSE_PARAM_USER_TYPE = "usertype"
let RESPONSE_PARAM_ALLOWED_CMTS = "allowed_cmts"

let RESPONSE_PARAM_IS_LOCKED = "is_locked"

let RESPONSE_PARAM_ADDRESS = "address"
let RESPONSE_PARAM_STATUS = "status"
let RESPONSE_PARAM_IS_VISIBLE = "is_visible"
let RESPONSE_PARAM_UNIT = "unit"
let RESPONSE_PARAM_TYPE = "type"
let RESPONSE_PARAM_CREATION_DATE = "creation_date"
let RESPONSE_PARAM_CLOSED_DATE = "closed_date"


let RESPONSE_PARAM_ASSIGNED_TO = "assigned_to"
let RESPONSE_PARAM_ASSIGNED_BY = "assigned_by"
let RESPONSE_PARAM_CUST_NAME = "custName"
let RESPONSE_PARAM_PHONE_NUMBER = "phone_number"
let RESPONSE_PARAM_TECHNICIAN_FEEDBACK = "technicians_feedback"
let RESPONSE_PARAM_PHOTOS = "photos"


let RESPONSE_PARAM_INTSALL_CM  = "installCm"
let RESPONSE_PARAM_UPSTREAM_MONITOR = "upstreamAnalyzerMonitor"
let RESPONSE_PARAM_UPSTREAM_ANALYZER = "upstreamAnalyzer"
let RESPONSE_PARAM_NIMBLE_SPECTRA = "nimbleSpectra"
let RESPONSE_PARAM_GEOCODE = "geocode"
let RESPONSE_PARAM_WO_SERVICE = "workorderservice"


let RESPONSE_PARAM_CMTS_ID = "cmtsID"
let RESPONSE_PARAM_MAC_ADDRESS = "mac_address"
let RESPONSE_PARAM_AGE = "age"
let RESPONSE_PARAM_TIMESTAMP = "timestamp"

let RESPONSE_PARAM_MODEM_MAC = "modemMAC"
let RESPONSE_PARAM_SEVERITY = "Severity"

let RESPONSE_PARAM_FINAL_STATUS = "final_status"
let RESPONSE_PARAM_REASON = "reason"
let RESPONSE_PARAM_INSTALLED_BY_USER = "installed_by_user"
let RESPONSE_PARAM_INSTALLATION_DATE = "installation_date"

let RESPONSE_PARAM_NAME = "name"
let RESPONSE_PARAM_VALUE = "value"

let RESPONSE_PARAM_CM_UNCORR = "cmUnCorrCw"
let RESPONSE_PARAM_CM_CORR = "cmCorrCw"
let RESPONSE_PARAM_POWER = "power"
let RESPONSE_PARAM_MER = "mer"

let RESPONSE_PARAM_WO_CMTS_ID = "cmts_id"
let RESPONSE_PARAM_LATITUDE = "latitude"
let RESPONSE_PARAM_LONGITUDE = "longitude"


let RESPONSE_PARAM_ICFR = "MTC"

let RESPONSE_PARAM_MR = "MRLevel"


let RESPONSE_PARAM_VTDR = "FarTDR"
let RESPONSE_PARAM_CORR = "Corr"





