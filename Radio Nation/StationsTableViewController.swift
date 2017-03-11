//
//  StationsTableViewController.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/10/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage

class StationsTableViewController: UITableViewController {

    var station = Radiostation()
    var radioStations = [Radiostation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioStations.removeAll(keepingCapacity: true)
        
        station.popularStations(page: 0, stationsLimitPerPage: 0) { (data, status, err, msg) in
            if status {
                let swiftyData = JSON(data)
                //print(swiftyData)
                
                guard let stationsData = swiftyData.array else {
                    print("NOT AN ARRAY")
                    return
                }
                
                for stations in stationsData {
                    self.station = Radiostation()
                    guard let listeners = stations["total_listeners"].int else {
                        continue
                    }
                    self.station.listeners = listeners
                   // print(listeners)
                    
                    guard let stationName = stations["name"].string else {
                        continue
                    }
                    self.station.name = stationName
                   // print(stationName)
                    print("Name:\(self.station.name)")
                    guard let country = stations["country"].string else {
                        continue
                    }
                    self.station.country = country
                    guard let website = stations["website"].string else {
                        continue
                    }
                    self.station.stationWebsite = website
                    print("Website:\(self.station.stationWebsite)")


                     let imageURL = stations["image"]["url"].string //else {
                      //  continue
                   // }
                    if imageURL != nil {
                    self.station.imgURL = imageURL!
                    }
                    
//                    guard let thumbnailURL = stations["image"]["url"]["thumb"]["url"].string else {
//                        continue
//                    }
//                    self.station.thumbURL = thumbnailURL
                   // print("THUMBNAIL:\(thumbnailURL)")
                   // print(imageURL)
                    
                    let category = stations["categories"].array
                    
                    for data in category! {
                        
                        guard let categTitle = data["title"].string else {
                            continue
                        }
                        self.station.categoryTitle = categTitle
                       // print(categTitle)
                    }
                    
                    let streams = stations["streams"].array

                    
                    for data in streams! {
                        guard let stream = data["stream"].string else {
                            continue
                        }
                        self.station.streamURL = stream
                        print("Stream URL:\(self.station.streamURL)")
                            print(stream)
                        guard let bitRate = data["bitrate"].int else {
                            continue
                        }
                        self.station.bitRate = bitRate
                        //print(bitRate)
                    }

                    self.radioStations.append(self.station)
                    
                    
                }
                self.tableView.reloadData()
                print(self.radioStations)
                
            } else {
                print(msg)
            }
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return radioStations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as! StationTableViewCell

        cell.titleLabel.text = radioStations[indexPath.row].name
        if radioStations[indexPath.row].imgURL != "" {
            cell.bgImage.af_setImage(withURL: URL(string:radioStations[indexPath.row].imgURL)!)
        }
        cell.countryLabel.text = radioStations[indexPath.row].country
        cell.numberOfListeners.text = String(radioStations[indexPath.row].listeners)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "radioDetail", sender: radioStations[indexPath.row])
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "radioDetail" {
            guard let playerVC = segue.destination as? MainViewController else {
                return
            }
            playerVC.radioStation = sender as! Radiostation
        }
    }
 

}
