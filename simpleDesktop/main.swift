//
//  main.swift
//  simpleDesktop
//
//  Created by Changzhi Li on 6/26/15.
//  Copyright (c) 2015 monster. All rights reserved.
//

import Foundation
import AppKit


class Debug: NSObject {
    var _debug = false
    func log(s: String) {
        println(s)
    }
}

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
    
    static func download(surl: String, path: String, fileName: String) -> Bool {
        let data = get(surl)
        let mgr = NSFileManager.defaultManager()
        mgr.changeCurrentDirectoryPath(path)
        return mgr.createFileAtPath(fileName, contents: data, attributes: nil)
    }
}

class ImageListReader: NSObject, NSXMLParserDelegate {
    var list = [String]()
    override init() {
        super.init()
    }
    
    func getLocalImage() {
        let mgr = NSFileManager.defaultManager()
        let files = mgr.contentsOfDirectoryAtPath("./image", error: nil)
        for i in files! {
            list.append((i as! String))
        }
    }
    
    func parseOnline() -> Bool {
        let htmlData = Http.get("http://simpledesktops.com/")
        var err:NSError?
        let xml = NSXMLDocument(data: htmlData, options: 1024, error: &err)
        let dom = NSXMLParser(data: xml!.XMLData)
        dom.delegate = self
        return dom.parse()
    }
    
    
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
            var range = img.rangeOfString(".png");
            //println(range)
            if range != nil {
                let imgSrc = img.substringToIndex(range!.endIndex)
                range = imgSrc.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch)
                let fname = imgSrc.substringFromIndex(range!.endIndex)
                Http.download(imgSrc, path: Application.imageDir, fileName: fname)
                println(fname)
                list.append(fname)
            }
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        //println(parseError)
    }
}

class DesktopImageManager: NSObject {
    static func setImage(var surl:String) -> Bool {
        if surl.substringWithRange(Range(start:  advance(surl.startIndex, 0), end: advance(surl.startIndex, 1))) != "/" {
            let mgr = NSFileManager.defaultManager()
            surl = mgr.currentDirectoryPath + "/" + surl
        }
        let workspace = NSWorkspace.sharedWorkspace()
        let scr = NSScreen.mainScreen()
        var opts = workspace.desktopImageOptionsForScreen(scr!)
        var err:NSError?
        let url = NSURL(fileURLWithPath: surl)
        println(url)
        return workspace.setDesktopImageURL(url!, forScreen: scr!, options: nil, error: &err)
    }
}

class Application: NSObject {
    static let lockFile = "./.lock"
    static let imageDir = "./image"
    static let interval: UInt32 = 5;
    let imageList: ImageListReader = ImageListReader()
    
    override init() {
        super.init()
    }
    
    func run () -> Int {
        _init()
        imageList.getLocalImage()
        while (true) {
            var imgPath = imageList.list[Int(arc4random()) % imageList.list.count]
            println("wocao " + imgPath)
            DesktopImageManager.setImage(Application.imageDir + "/" + imgPath)
            sleep(Application.interval)
        }
        return 0
    }
    
    func _init() {
        let mgr = NSFileManager.defaultManager()
        if mgr.fileExistsAtPath(Application.lockFile) {
            return
        }
        mgr.createDirectoryAtPath(Application.imageDir, withIntermediateDirectories: true, attributes: nil, error: nil)
        mgr.createFileAtPath(Application.lockFile, contents: nil, attributes: nil)
        imageList.parseOnline()
    }
}

Application().run()