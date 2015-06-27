//
//  main.swift
//  simpleDesktop
//
//  Created by Changzhi Li on 6/26/15.
//  Copyright (c) 2015 monster. All rights reserved.
//

import Foundation
import AppKit

println("Hello, World!")



class Http: NSObject {
    static func get(surl: String) -> NSData {
        let url = NSURL(string: surl)
        let req = NSURLRequest(URL: url!)
        var resp:NSURLResponse?
        var err:NSError?
        var data = NSURLConnection.sendSynchronousRequest(req, returningResponse: &resp, error: &err)
        if err == nil{
            //println(resp)
            return data!
        }
        println(err)
        return NSData()
    }
    
    static func download(surl: String, path: String) -> Bool {
        let data = get(surl)
        return true
    }
}

class ImageListReader: NSObject, NSXMLParserDelegate {
    override init() {
        super.init()
        
        let htmlData = Http.get("http://simpledesktops.com/")
        var err:NSError?
        let xml = NSXMLDocument(data: htmlData, options: 1024, error: &err)
        let dom = NSXMLParser(data: xml!.XMLData)
        dom.delegate = self
        println(dom.parse())    }
    
    func parserDidStartDocument(parser: NSXMLParser) {
        //println("parserDidStartDocument")
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        //println("parserDidStartDocument")
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        /*var x = attributeDict["class"]
        if x != nil && (x! as! String) == "desktop"{
            println(elementName, parser)
            //println(elementName)
        }*/
        if elementName == "img" {
            var img = (attributeDict["src"]! as! String)
            //println(img)
            let range = img.rangeOfString(".png");
            //println(range)
            if range != nil {
                println(img.substringToIndex(range!.endIndex))
            }
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        //println(parseError)
    }
}

class DesktopImageManager: NSObject {
    func setImage(surl:String) -> Bool {
        let mgr = NSWorkspace.sharedWorkspace()
        let scr = NSScreen.mainScreen()
        var opts = mgr.desktopImageOptionsForScreen(scr!)
        var err:NSError?
        let url = NSURL(fileURLWithPath: surl)
        return mgr.setDesktopImageURL(url!, forScreen: scr!, options: nil, error: &err)
    }
}

//ImageListReader()
DesktopImageManager().setImage("/Users/monster/Desktop/soaring_mountains.png");