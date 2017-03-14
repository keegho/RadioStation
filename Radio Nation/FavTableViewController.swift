//
//  FavTableViewController.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/13/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class FavTableViewController: UITableViewController {
    
    //var station = Radiostation()
    var stations = [Station]()
    var loadedImageName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  emptyTableView.isHidden = true
        navigationItem.title = "Favorites"
        grabStationsFromDB()
        
//        if stations.isEmpty {
//            emptyTableView.isHidden = false
//            tableView.isHidden = true
//        }
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
        return stations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavTableViewCell
        
        editCellView(cell: cell)
        
        if stations[indexPath.row].avatarUrl != nil && stations[indexPath.row].avatarUrl != "" {
            cell.avatarImage.af_setImage(withURL: URL(string: stations[indexPath.row].avatarUrl!)!)
        } else {
            cell.avatarImage.image = #imageLiteral(resourceName: "radioAvatar")
        }
        
        loadedImageName = (stations[indexPath.row].countrycode)!.lowercased() + ".png"
        cell.countryCodeLabel.text = stations[indexPath.row].countrycode
        cell.flagImageView.image = UIImage(named: loadedImageName)
        cell.stationCategoryLabel.text = stations[indexPath.row].category
        cell.stationLabelName.text = stations[indexPath.row].name
        

        return cell
    }
    
    func editCellView(cell:FavTableViewCell) {
        
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.width/2
        //cell.bgImage.layer.borderWidth = 1.5
        // cell.bgImage.layer.borderColor = UIColor(red:0.60, green:0.07, blue:0.71, alpha:1.0).cgColor
        cell.avatarImage.clipsToBounds = true
        //        cell.barCategoryField.layer.cornerRadius = cell.barCategoryField.frame.width/2
        //        cell.barLogoImageView.layer.cornerRadius = cell.barLogoImageView.frame.width/2
        //        cell.barLogoImageView.layer.borderWidth = 2.0
        //        cell.barLogoImageView.layer.borderColor = UIColor.green.cgColor
        //        cell.barLogoImageView.clipsToBounds = true
        //        cell.barDescriptionField.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
    }

 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Radioplayer.sharedInstance.pause()
        loadedImageName = ((stations[indexPath.row].countrycode)?.lowercased())! + ".png"
        let station = stations[indexPath.row]
        let stationSend = Radiostation()
        
        stationSend.imgURL = station.avatarUrl!
        stationSend.categoryTitle = station.category!
        stationSend.name = station.name!
        stationSend.streamURL = station.streamUrl!
        performSegue(withIdentifier: "mainPlayer", sender: stationSend)
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteStationFromDB(index: indexPath.row)
            stations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
       // }
    }
 

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
    
    //Create context for CoreData
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //Get fav stations from core data db
    func grabStationsFromDB() {
        
        let fetchRequest: NSFetchRequest<Station> = Station.fetchRequest()
        
        do {
            let results = try getContext().fetch(fetchRequest) 
            for result in results {
                stations.append(result)
                //print(stations)
                
            }
            self.tableView.reloadData()
        } catch let err as Error? {
            
            print("Error fetching results", err!)
        }
        
    }
        
    func deleteStationFromDB(index: Int) {
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Station> = Station.fetchRequest()
        
        let results = try? context.fetch(fetchRequest)
        let resultsStation = results! as [Station]
        context.delete(resultsStation[index])

        do {
            try context.save()
            print("Deleted")
        } catch let err as Error? {
            
            print("Error deleting results", err!)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mainPlayer" {
            
            guard let playerVC = segue.destination as? MainViewController else {
                return
            }
        
            playerVC.radioStation = sender as! Radiostation
            playerVC.flagImageString = loadedImageName
        }
    }
    

}
