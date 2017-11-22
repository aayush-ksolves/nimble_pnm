//
//  AlamofireHelper.swift
//  Promojuice
//
//  Created by KSolves on 21/11/16.
//  Copyright © 2016 KSolves India Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire


/// Utility helper using alamofire for http requests 
class AlamofireHelper: NSObject {
   
    
    /// To make JSON POST requests using authorization token in request header
    ///
    /// - Parameters:
    ///   - urlString: The url at which the request is to be made
    ///   - parameters: The parameters to be passed in body of request of type [String:Any]
    ///   - sucessCompletionHadler: The closure to be called if the request returns a http status of 200
    ///   - failureCompletionHandler: The closure to be called if http status was not 200 or there exist some JSON deserealising error
    func makePostRequestWithAuthorizationHeaderTo(url urlString:String,withParameters parameters:[String:Any]!, withLoaderMessage : String = "Loading...", isStandAloneURL :Bool = false, sucessCompletionHadler:@escaping (NSDictionary)->Void, failureCompletionHandler:@escaping (String,String) -> Void) {
        
        var url : String;
        
        if isStandAloneURL{
            url = urlString
            
        }else{
            url = BASE_URL + urlString
        }
        
        //Debug Mode
        printServiceURLWithParamters(withURL: url, withParameters: parameters);
        
        //Sliding In Loader View Controller
        APP_DELEGATE.presentLoader(withMessage: withLoaderMessage)
        
        Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            responseBundle in
            
            let httpStatusCode = responseBundle.response?.statusCode
            let requestStatus = responseBundle.result
            
            print(httpStatusCode!)
            print(requestStatus)
            
            //Sliding Out Loader View Controller
            APP_DELEGATE.hideLoader()
            
            switch requestStatus{
            case .success:
                
                //Getting Data As JSON Serialization Succeded
                let responseDataBundle = responseBundle.result.value
                
                if httpStatusCode == 200{
                    
                    //Successfull Request With Valid JSON Serialization
                    makeMeaningFullLog(withObject: responseDataBundle, withDescription: "REQUEST SUCCESS DATA");
                    sucessCompletionHadler(responseDataBundle! as! NSDictionary)
                    
                }else{
                    
                    //Invoking Only when http status !200 but in 200..299
                    failureCompletionHandler(ERROR_TITLE_TECHNICAL_ERROR,ERROR_MSG_TECHNICAL_ERROR)
                    
                    makeMeaningFullLog(withObject: responseDataBundle, withDescription: "Chained Log - Httpstatus not 200 but =  \(String(describing: httpStatusCode))" )
                    //Perform Graceful Handling
                    
                }
                break
                
            case .failure:
                //No internet -- Request Not Succeded (Not 200 - 299)
                //Perform Graceful Handling
                if httpStatusCode == 500 {
                    
                    print("ERROR 500")
                    failureCompletionHandler(ERROR_TITLE_TECHNICAL_ERROR,ERROR_MSG_TECHNICAL_ERROR)
                    
                }else{
                    
                    failureCompletionHandler(ERROR_TITLE_NO_INTERNET,ERROR_MSG_NO_INTERNET)
                    makeMeaningFullLog(withObject: responseBundle , withDescription: "Chained Log HTTP Status Not in 200-299 OR No Internet with status == \(String(describing: httpStatusCode))")
                }
                
                break
            }
        })
    }
    
    
    func makePostRequestWithAuthorizationHeaderWithoutLoaderTo(url urlString:String,withParameters parameters:[String:Any]!, isStandAloneURL :Bool = false, sucessCompletionHadler:@escaping (NSDictionary)->Void, failureCompletionHandler:@escaping (String,String) -> Void) {
        
        var url : String;
        
        if isStandAloneURL{
            url = urlString
            
        }else{
            url = BASE_URL + urlString
        }
        
        
        //Debug Mode
        printServiceURLWithParamters(withURL: url, withParameters: parameters);
        
    
        Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            responseBundle in
            
            let httpStatusCode = responseBundle.response?.statusCode
            let requestStatus = responseBundle.result
            
            switch requestStatus{
            case .success:
                
                //Getting Data As JSON Serialization Succeded
                let responseDataBundle = responseBundle.result.value
                
                if httpStatusCode == 200{
                    
                    //Successfull Request With Valid JSON Serialization
                    makeMeaningFullLog(withObject: responseDataBundle, withDescription: "REQUEST SUCCESS DATA");
                    sucessCompletionHadler(responseDataBundle! as! NSDictionary)
                    
                    
                }else{
                    
                    //Invoking Only when http status !200 but in 200..299
                    failureCompletionHandler(ERROR_TITLE_TECHNICAL_ERROR,ERROR_MSG_TECHNICAL_ERROR)
                    
                    makeMeaningFullLog(withObject: responseDataBundle, withDescription: "Chained Log - Httpstatus not 200 but =  \(String(describing: httpStatusCode))" )
                    //Perform Graceful Handling
                    
                }
                break
                
            case .failure:
                //No internet -- Request Not Succeded (Not 200 - 299)
                //Perform Graceful Handling
                if httpStatusCode == 500 {
                    
                    print("ERROR 500")
                    failureCompletionHandler(ERROR_TITLE_TECHNICAL_ERROR,ERROR_MSG_TECHNICAL_ERROR)
                    
                }else{
                    
                    failureCompletionHandler(ERROR_TITLE_NO_INTERNET,ERROR_MSG_NO_INTERNET)
                    makeMeaningFullLog(withObject: responseBundle , withDescription: "Chained Log HTTP Status Not in 200-299 OR No Internet with status == \(String(describing: httpStatusCode))")
                }
                
                break
            }
        })
    }
    
    
    func uploadImageWithData(url urlString:String,withParameters parameters:[String:Any]!,bundleImagesArray imageBundleArray:NSMutableArray, withLoaderMessage : String = "Loading...", sucessCompletionHadler:@escaping (NSDictionary)->Void, failureCompletionHandler:@escaping (String, String) -> Void){
        
        let url = BASE_URL + urlString
        
        //Debug Mode
        printServiceURLWithParamters(withURL: url, withParameters: parameters);
        
        //Sliding In Loader View Controller
        APP_DELEGATE.presentLoader(withMessage: withLoaderMessage)
        
        Alamofire.upload(multipartFormData: {
            multipartFormData in
            
            //Filiing Parameters From ImageDict
            for (key,value) in parameters{
                
                let stringValue = String(describing: value)
                multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
            }
            
            for eachDictionary in imageBundleArray{
                let tempDict = eachDictionary as! NSDictionary
                let imageName = tempDict.value(forKey: PARAM_NAME)! as! String
                let imageValue = tempDict.value(forKey: PARAM_IMAGE) as! UIImage
                
                let imageData = UIImagePNGRepresentation(imageValue)!
                multipartFormData.append(imageData, withName: imageName, fileName: "\(imageName).png", mimeType: "image/png")
            }
            
            print("Here")
            print(imageBundleArray)
            print(parameters)
            
        }, to: url , method: .post ,encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON {
                    responseBundle in
                    
                    let httpStatusCode = responseBundle.response?.statusCode
                    let requestStatus = responseBundle.result
                    
                    //Sliding Out Loader View Controller
                    APP_DELEGATE.hideLoader()
                    
                    switch requestStatus{
                    case .success:
                        
                        //Getting Data As JSON Serialization Succeded
                        let responseDataBundle = responseBundle.result.value
                        
                        if httpStatusCode == 200{
                            
                            //Successfull Request With Valid JSON Serialization
                            makeMeaningFullLog(withObject: responseDataBundle, withDescription: "REQUEST SUCCESS DATA");
                            sucessCompletionHadler(responseDataBundle! as! NSDictionary)
                            
                            
                        }else{
                            
                            print("C")
                            //Invoking Only when http status !200 but in 200..299
                            failureCompletionHandler(ERROR_TITLE_TECHNICAL_ERROR,ERROR_MSG_TECHNICAL_ERROR)
                            
                            makeMeaningFullLog(withObject: responseDataBundle, withDescription: "Chained Log - Httpstatus not 200 but =  \(String(describing: httpStatusCode))" )
                            
                            //Perform Graceful Handling
                            
                        }
                        break
                        
                    case .failure:
                        print(responseBundle)
                        
                        //No internet -- Request Not Succeded (Not 200 - 299)
                        //Perform Graceful Handling
                        if httpStatusCode == 500 {
                            
                            failureCompletionHandler(ERROR_TITLE_TECHNICAL_ERROR,ERROR_MSG_TECHNICAL_ERROR)
                            
                        }else{
                            
                            failureCompletionHandler(ERROR_TITLE_NO_INTERNET,ERROR_MSG_NO_INTERNET)
                            makeMeaningFullLog(withObject: responseBundle , withDescription: "Chained Log HTTP Status Not in 200-299 OR No Internet with status == \(String(describing: httpStatusCode))")
                        }
                        
                        break
                    }
                }
            case .failure(let encodingError):
                failureCompletionHandler(ALERT_TITLE_APP_NAME,"Multi Part Form data request not build correctly!")
                //Sliding Out Loader View Controller
                APP_DELEGATE.hideLoader()
                makeMeaningFullLog(withObject: encodingError, withDescription: "Multipart Form Data Request not Encoded Successfully")
            }
        })
    }
    
}

func makeMeaningFullLog(withObject object:Any!, withDescription description:String){
    print("\n----From Alamofire Helper----")
    print(description)
    print(object!)
    print("---- Alamofire Helper End----")
}

func printServiceURLWithParamters(withURL url:String, withParameters parameters:Any!){
    print("\nService Debugger:-")
    print("URL Hit -> \(url)")
    if parameters != nil{
        print("Paramters Sent -> \(parameters! as! NSDictionary)")
        
    }
}

