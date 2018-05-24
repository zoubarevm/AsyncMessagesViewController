//
//  MediaUtils.swift
//  AsyncMessagesViewController
//
//  Created by Chilla Tenga on 2018-05-07.
//

import Foundation
import AVFoundation

public class MediaUtils {
    
    public static func cacheImage(_ urlName: String?){
        //sample image path: "https://s3.amazonaws.com/zepeel-develop/images/9c2689ad-e1d0-4c14-8ee1-86c3a52bb62d.JPG"
        if(urlName != nil){
            let path = urlName!.components(separatedBy: "/");
            print("let's try and cache these images");
            
            if !path.isEmpty, let fileName = path.last{
                print("This is the filename of a message: \(fileName)");
            }
        }
        
        
    }
    
    public static func getThumbnailFromVideo(urlString: String,  _ response: @escaping (_ success: UIImage) -> Void){
        let urlPath = urlString.components(separatedBy: "/")
        var fileName: String?
        let fileManager = FileManager.default;
        
        if !urlPath.isEmpty && !(urlPath.last?.isEmpty)!{
            fileName = (urlPath.last! as NSString).deletingPathExtension + ".jpeg";
            print("path to the video thumbnail file: \(fileName!)")
            
            let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
            let url = URL(fileURLWithPath: path);
            let filePath = url.appendingPathComponent(fileName!)
            if(fileManager.fileExists(atPath: filePath.path)){
                let _image = UIImage(contentsOfFile: filePath.path);
                if(_image != nil){
                    response(_image!);
                    return;
                }
            }
            
        }
        
        MediaUtils.downloadThumbnailWith(videoUrlString: urlString) { _returnedImage in
            if(fileName != nil){
                if(MediaUtils.writeImageToCache(fileName: fileName!, imageToSave: _returnedImage, searchPathDirectory: .cachesDirectory)){
                    response(_returnedImage);
                }
            }
        }
        
        
    }
    
    public static func downloadImageData(urlString: String, _ response: @escaping (_ success: UIImage) -> Void) {
        if let url = URL(string: urlString) {
            DispatchQueue.global(qos: .background).async(execute: { () -> Void in
                if let imageData = try? Data(contentsOf: url) {
                    print("Downloaded image")
                    let image = UIImage(data: imageData)
                    //self._image = image
                    response(image!)
                }
            })
        }
    }
    
    public static func downloadThumbnailWith(videoUrlString: String,  _ response: @escaping (_ success: UIImage) -> Void){
        
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            let asset = AVAsset(url: URL(string: videoUrlString)!)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(Float64(1), 100)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                response(thumbnail)
            } catch {
                print(error)
            }
        })
        
    }
    
    public static func writeImageToCache(fileName: String, imageToSave: UIImage, searchPathDirectory: FileManager.SearchPathDirectory = .libraryDirectory ) -> Bool{
        do {
            let fileManager = FileManager.default;
            let libraryDirectory = try fileManager.url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: false);
            
            
            //print("let's try and cache these images");
            
            let fileURL = libraryDirectory.appendingPathComponent(fileName)
            
            if let imageData = UIImageJPEGRepresentation(imageToSave, 1){
                try imageData.write(to: fileURL)
                print("image was succesfully saved");
                // in the future now, you can just check the cached folder for the image;
                //response(_returnedImage);
                return true
            }
            return false
        }
        catch {
            print(error)
            return false
        }
    }
    
    public static func getCachedImage(urlString: String, _ response: @escaping (_ success: UIImage) -> Void){
        let urlPath = urlString.components(separatedBy: "/")
        var fileName: String?
        let fileManager = FileManager.default;
        
        if !urlPath.isEmpty && !(urlPath.last?.isEmpty)!{
            fileName = urlPath.last
            //print("This is the filename of the image in this message: \(fileName!)");
            
            let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
            let url = URL(fileURLWithPath: path);
            let filePath = url.appendingPathComponent(fileName!)
            if(fileManager.fileExists(atPath: filePath.path)){
                let _image = UIImage(contentsOfFile: filePath.path);
                if(_image != nil){
                    response(_image!);
                    return;
                }
            }
            
        }
        
        
        
        MediaUtils.downloadImageData(urlString: urlString, { _returnedImage in
            if(fileName != nil){
                if(MediaUtils.writeImageToCache(fileName: fileName!, imageToSave: _returnedImage)){
                    response(_returnedImage);
                }
            }
            
        })
    }
}
