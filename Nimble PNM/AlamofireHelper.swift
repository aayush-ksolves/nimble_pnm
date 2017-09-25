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

