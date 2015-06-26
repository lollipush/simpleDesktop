//
//  main.swift
//  simpleDesktop
//
//  Created by Changzhi Li on 6/26/15.
//  Copyright (c) 2015 monster. All rights reserved.
//

import Foundation

println("Hello, World!")

func httpGet(surl: String) -> NSData {
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

class ImageListReader: NSObject, NSXMLParserDelegate {
    override init() {
        super.init()
        
        let htmlData = httpGet("http://simpledesktops.com/")
        
        var err:NSError?
        //println(NSXMLDocumentTidyXML)
        let xml = NSXMLDocument(data: htmlData, options: 1024, error: &err)
        //println(xml)
        
        let dom = NSXMLParser(data: xml!.XMLData)
        dom.delegate = self
        println(dom.parse())
        //println(dom)
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
    
    func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
        //println("sb")
    }
}

ImageListReader()