//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
    
    let name: String
    let id: Int
    let instagramURL: URL
    var description: String {
        return "Nice to meet you, I'm \(name)"
    }
}

class InstaCatTableViewController: UITableViewController {
    
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL),
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData) else {
                return
        }
        
        self.instaCats = instaCatsAll
      
    }
    

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstaCatCellIdentifier", for: indexPath)
        cell.textLabel?.text = instaCats[indexPath.row].name
        cell.detailTextLabel?.text = instaCats[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         UIApplication.shared.open(instaCats[indexPath.row].instagramURL)
    }
    
    // MARK:Data
    
    internal func getResourceURL(from fileName: String) -> URL? {
        
        // 1. There are many ways of doing this parsing, we're going to practice String traversal
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        // 2. The upperbound of a range represents the position following the last position in the range, thus we can use it
        // to effectively "skip" the "." for the extension range
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        // 3. Here is where Bundle.main comes into play
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
        
        return fileURL
    }
    
    
    internal func getData(from url: URL) -> Data? {
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let catDict = instaCatJSONData as? [String:[[String:Any]]]{
                if let cats = catDict["cats"] {
                    for c in cats {
                        if let catName = c["name"] as? String,
                        let catId = c["cat_id"] as? String,
                            let caturl = c["instagram"] as? String {
                            let intaCat = InstaCat(name: catName, id:Int(catId)!, instagramURL: URL(string:caturl)!)
                            instaCats.append(intaCat)
                        }
                    
                    }
                }
         
            }
                   return instaCats
        }
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }
    
    

}
