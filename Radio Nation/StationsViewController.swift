//
//  StationsViewController.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/14/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage
import CoreData

class StationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet var buttomBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pauseButton: UIBarButtonItem!
    @IBOutlet var playButton: UIBarButtonItem!

    
    var station = Radiostation()
    var radioStations = [Radiostation]()
    var filteredCategory = "All"
    var filteredCountry = "All"
    var filteredCountryCode = "aa"
    var filteredCategoryID = 0
    var filterStatus = 0 //Zero means all
    var page = 1
    
  //  var moreData = true
    
    var countBefore = Int()
    
    var errorMsg = String()
    
    var flagsNamesArray = [String]()
    var loadedImageName = String()
    
    var activityIndicator: UIActivityIndicatorView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.clipsToBounds = true
        activityIndicator.layer.cornerRadius = 4
        activityIndicator.backgroundColor = UIColor(red:0.18, green:0.24, blue:0.31, alpha:0.8)
        view.addSubview(activityIndicator)
        
        let f = Bundle.main.url(forResource: "Flags", withExtension: nil)!
        let fm = FileManager()
        let longFlagsNamesArray = try! fm.contentsOfDirectory(at: f, includingPropertiesForKeys: nil, options: [])
        
        for i in 0 ..< longFlagsNamesArray.count {
            flagsNamesArray.append(longFlagsNamesArray[i].lastPathComponent)
        }
       // buttomBar.backgroundColor = UIColor(red:0.64, green:0.11, blue:0.13, alpha:0.6)
       // buttomBar.isTranslucent = true
       // buttomBar.tintColor = UIColor.white
        
        if !(Radioplayer.sharedInstance.currentlyPLaying()) {
            buttomBar.isHidden = true
        } else {
            
            pauseButton.isEnabled = true
            playButton.isEnabled = false
        }
        

        
        
        
        
        let userDefaults = UserDefaults()
        
        //Checking if there is previous saved filtered data
        //        if let filteredCountryCodeTest = userDefaults.object(forKey: "filteredCountry") as? String {
        //            filteredCountry = filteredCountryCodeTest
        //        }
        //        if let filteredCategoryTest = userDefaults.object(forKey: "filteredCategory") as? String {
        //            filteredCategory = filteredCategoryTest
        //        }
        
        radioStations.removeAll(keepingCapacity: true)
        
        //Nothing filtered
        if filteredCategory == "All" && filteredCountry == "All" {
            
            loadStationsByMostPopular(page: page)
            filterStatus = 0
            //Only per category api call
        } else if filteredCategory != "All" && filteredCountry == "All" {
            
            loadStationsByCategory()
            filterStatus = 1
            //Only per country api all
        } else if filteredCountry != "All" && filteredCategory == "All" {
            
            loadStationsByCountry(page: page)
            filterStatus = 2
            //Both filtered
        } else {
            
        }
        
        //Save filters to use it later
        userDefaults.set(filteredCountryCode, forKey: "filteredCountry")
        userDefaults.set(filteredCategory, forKey: "filteredCategory")
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if Radioplayer.sharedInstance.currentlyPLaying() {
            
            buttomBar.isHidden = false
            pauseButton.isEnabled = true
            playButton.isEnabled = false
            
        } else {
            
            pauseButton.isEnabled = false
            playButton.isEnabled = true
            buttomBar.isHidden = true
        }
        
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButtonAction(_ sender: UIBarButtonItem) {
        Radioplayer.sharedInstance.play()
        playButton.isEnabled = false
        pauseButton.isEnabled = true
    }
    @IBAction func pauseButtonAction(_ sender: UIBarButtonItem) {
        Radioplayer.sharedInstance.pause()
        pauseButton.isEnabled = false
        playButton.isEnabled = true
    }
    
    func loadStationsByMostPopular(page: Int) {
        //DispatchQueue.main.async {
        self.activityIndicator.startAnimating()
        //}
        
        station.popularStations(page: page, stationsLimitPerPage: 20) { (data, status, err, msg) in
            if status {
                
                if data == nil {
                    
                    self.station.moreData = false
                    print("return")
                    return
                }
                
                let swiftyData = JSON(data)
                //print(swiftyData)
                
                guard let stationsData = swiftyData.array else {
                    print("NOT AN ARRAY")
                    return
                }
                
                if stationsData.count == 0 {
                    
                    self.station.moreData = false
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
                    //print("Name:\(self.station.name)")
                    guard let country = stations["country"].string else {
                        continue
                    }
                    self.station.country = country
                    guard let website = stations["website"].string else {
                        continue
                    }
                    self.station.stationWebsite = website
                    //print("Website:\(self.station.stationWebsite)")
                    
                    self.station.id = stations["id"].int32!
                    //print("staionID:\(self.station.id)")
                    
                    
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
                       // print("Stream URL:\(self.station.streamURL)")
                       // print(stream)
                        guard let bitRate = data["bitrate"].int else {
                            continue
                        }
                        self.station.bitRate = bitRate
                        //print(bitRate)
                    }
                    
                    self.radioStations.append(self.station)
                    
                    
                }
                self.tableView.reloadData()
               // print(self.radioStations)
                self.activityIndicator.stopAnimating()
            } else {
                print(msg!)
                self.errorMsg = msg!
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    func loadStationsByCategory() {
        activityIndicator.startAnimating()
        station.categoriezedStation(categoryID: filteredCategoryID, completion: { (data, status, err, msg) in
            if status {
                let swiftyJSON = JSON(data)
                // print(swiftyJSON)
                
                guard let stationsData = swiftyJSON.array else {
                    print("NOT AN ARRAY")
                    return
                }
                
                if stationsData.count == 0 {
                    
                    self.station.moreData = false
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
                    //print("Name:\(self.station.name)")
                    guard let country = stations["country"].string else {
                        continue
                    }
                    self.station.country = country
                    guard let website = stations["website"].string else {
                        continue
                    }
                    self.station.stationWebsite = website
                    //print("Website:\(self.station.stationWebsite)")
                    
                    
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
                    self.station.id = stations["id"].int32!
                    
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
                        //print("Stream URL:\(self.station.streamURL)")
                        //print(stream)
                        guard let bitRate = data["bitrate"].int else {
                            continue
                        }
                        self.station.bitRate = bitRate
                        //print(bitRate)
                    }
                    
                    self.radioStations.append(self.station)
                    
                    
                }
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            } else {
                print(msg!)
                self.errorMsg = msg!
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    func loadStationsByCountry(page: Int) {
        activityIndicator.startAnimating()
        station.countryStations(countryCode: filteredCountryCode, page: page, stationsLimitPerPage: 20, completion: { (data, status, err, msg) in
            
            if status {
                
                let swiftyJSON = JSON(data)
                // print(swiftyJSON)
                
                guard let stationsData = swiftyJSON.array else {
                    print("NOT AN ARRAY")
                    return
                }
                
                if stationsData.count == 0 {
                    
                    self.station.moreData = false
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
                    //print("Name:\(self.station.name)")
                    guard let country = stations["country"].string else {
                        continue
                    }
                    self.station.country = country
                    guard let website = stations["website"].string else {
                        continue
                    }
                    self.station.stationWebsite = website
                    //print("Website:\(self.station.stationWebsite)")
                    
                    
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
                    self.station.id = stations["id"].int32!
                    
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
                        //print("Stream URL:\(self.station.streamURL)")
                        //print(stream)
                        guard let bitRate = data["bitrate"].int else {
                            continue
                        }
                        self.station.bitRate = bitRate
                        //print(bitRate)
                    }
                    
                    self.radioStations.append(self.station)
                    
                    
                }
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            } else {
                print(msg!)
                self.errorMsg = msg!
                self.activityIndicator.stopAnimating()
            }
        })
        
    }

    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let numOfSections: Int = 1
        if radioStations.count > 0
        {
            tableView.separatorStyle = .singleLine
            //numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            
            let bgView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            
            let noDataLabel = UILabel(frame: CGRect(x: (bgView.frame.midX - (bgView.bounds.width)*0.5), y: ((bgView.frame.midY + bgView.bounds.height/2)*0.50), width: bgView.bounds.width, height: bgView.bounds.height/3))
            
            //This algorithm not working yet
            if errorMsg == "" {
                noDataLabel.text = "Loading Stations..."
            } else if radioStations.count == 0 {
                noDataLabel.text = "No Stations available"
            } else {
                noDataLabel.text = errorMsg
            }
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            
            tableView.separatorStyle  = .none
            bgView.addSubview(noDataLabel)
            tableView.backgroundView  = bgView
            
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return radioStations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as! StationsTableViewCell
        
        editCellView(cell: cell)
        
        //Long Tap Guesture for add to fav
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addToFav))
        longPressGesture.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressGesture)
        
        
        cell.titleLabel.text = radioStations[indexPath.row].name
        if radioStations[indexPath.row].imgURL != "" {
            cell.bgImage.af_setImage(withURL: URL(string:radioStations[indexPath.row].imgURL)!)
        } else {
            cell.bgImage.image = #imageLiteral(resourceName: "radioAvatar")
        }
        
        loadedImageName = (radioStations[indexPath.row].country).lowercased() + ".png"
        cell.countryFlagImageView.image = UIImage(named: loadedImageName)
        cell.categoryLabel.text = radioStations[indexPath.row].categoryTitle
        cell.countryLabel.text = radioStations[indexPath.row].country
        
        if let bitRate = radioStations[indexPath.row].bitRate {
            cell.bitRateLabel.text = String(bitRate)
        }
        
        if isFavorted(stationID: radioStations[indexPath.row].id) {
            cell.heartIcon.image = #imageLiteral(resourceName: "heartFav")
        } else {
            cell.heartIcon.image = #imageLiteral(resourceName: "heartNoFav")
        }

        cell.numberOfListeners.text = String(radioStations[indexPath.row].listeners)
        
//        let userDefaults = UserDefaults.standard
//        if let img = cell.bgImage.image {
//            
//            if let savingImage = UIImagePNGRepresentation(img) {
//                userDefaults.set(savingImage, forKey: "avatarImg")
//            }
//        }
        //radioStations[indexPath.row].image = cell.bgImage.image!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Radioplayer.sharedInstance.pause()
        loadedImageName = (radioStations[indexPath.row].country).lowercased() + ".png"
        performSegue(withIdentifier: "radioDetail", sender: radioStations[indexPath.row])
    }
    

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if station.moreData {
            let lastElement = radioStations.count - 1
            if indexPath.row == lastElement {
                page += 1
                switch filterStatus {
                case 0:
                    loadStationsByMostPopular(page: page)
            
                case 1:
                    loadStationsByCategory()
                case 2:
                    
                    loadStationsByCountry(page: page)
                default:
                    return
                }
                
            }
        }
    }
    
    func checkForMoreData() {
        
    }
    
    
    func editCellView(cell:StationsTableViewCell) {
        
        cell.bgImage.layer.cornerRadius = cell.bgImage.frame.width/2
        //cell.bgImage.layer.borderWidth = 1.5
        // cell.bgImage.layer.borderColor = UIColor(red:0.60, green:0.07, blue:0.71, alpha:1.0).cgColor
        cell.titleLabel.clipsToBounds = true
        cell.titleLabel.layer.cornerRadius = 4
        cell.titleLabel.layer.masksToBounds = false
        cell.bgImage.clipsToBounds = true
        //        cell.barCategoryField.layer.cornerRadius = cell.barCategoryField.frame.width/2
        //        cell.barLogoImageView.layer.cornerRadius = cell.barLogoImageView.frame.width/2
        //        cell.barLogoImageView.layer.borderWidth = 2.0
        //        cell.barLogoImageView.layer.borderColor = UIColor.green.cgColor
        //        cell.barLogoImageView.clipsToBounds = true
        //        cell.barDescriptionField.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
    }
    
    
    //Function after long press detection on any table row
    func addToFav(longPressureGesture: UILongPressGestureRecognizer) {
        
        let p = longPressureGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressureGesture.state == UIGestureRecognizerState.began) {
            
                let cell = tableView.cellForRow(at: indexPath!) as! StationsTableViewCell
                //let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath!) as! StationsTableViewCell
                cell.heartIcon.image = #imageLiteral(resourceName: "heartFav")
                let avatarImage = cell.bgImage.image
                let stationName = radioStations[indexPath!.row].name
                let stationCountryCode = radioStations[indexPath!.row].country
                let stationStream = radioStations[indexPath!.row].streamURL
                let imageURL = radioStations[indexPath!.row].imgURL
                let stationCategory = radioStations[indexPath!.row].categoryTitle
                let stationid = radioStations[indexPath!.row].id
            
            
                let imageData = UIImagePNGRepresentation(avatarImage!) as NSData?
            
            addFavToDB(stationID: stationid, name: stationName, category: stationCategory, avatarURL: imageURL, countryCode: stationCountryCode, streamURL: stationStream, image: imageData!)
            
            // print("Long press on row, at \(indexPath!.row)")
            
        }
    }
    
    //Create context for CoreData
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    //Save station favorated to core data
    func addFavToDB(stationID: Int32, name:String, category:String, avatarURL: String, countryCode:String, streamURL: String, image: NSData) {
        
        let context = getContext()
        
        //Fetch request from db
        let fetchRequest: NSFetchRequest<Station> = Station.fetchRequest()
        //Check for a certain query
        let predicate = NSPredicate(format: "stationId == %d", stationID)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try getContext().fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    //Don't save
                    print("Already exists in fav")
                    
                //Continue to save
                } else {
                    
                    let entity = NSEntityDescription.entity(forEntityName: "Station", in: context)
                    let station = Station(entity: entity!, insertInto: context)
                    
                    station.imageData = image
                    station.avatarUrl = avatarURL
                    station.category = category
                    station.countrycode = countryCode
                    station.streamUrl = streamURL
                    station.name = name
                    station.stationId = stationID
                    
                    
                    //Saving
                    do {
                        try context.save()
                        print("Saved")
                    } catch let err as Error? {
                        print("Error not saved:", err!)
                    }

                }

            } catch let err as Error? {
                
                print("Error fetching results", err!)
            }
 
    }
    
    //Check if favorated
    func isFavorted(stationID: Int32) -> Bool {
        
        //Fetch request from db
        let fetchRequest: NSFetchRequest<Station> = Station.fetchRequest()
        //Check for a certain query
        let predicate = NSPredicate(format: "stationId == %d", stationID)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            
            return false
        }
    }



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
            playerVC.flagImageString = loadedImageName
        }
    }

}
