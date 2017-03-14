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
    
    var flagsNamesArray = [String]()
    var loadedImageName = String()
    
    var activityIndicator: UIActivityIndicatorView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        let f = Bundle.main.url(forResource: "Flags", withExtension: nil)!
        let fm = FileManager()
        let longFlagsNamesArray = try! fm.contentsOfDirectory(at: f, includingPropertiesForKeys: nil, options: [])
        
        for i in 0 ..< longFlagsNamesArray.count {
            flagsNamesArray.append(longFlagsNamesArray[i].lastPathComponent)
        }
        buttomBar.backgroundColor = UIColor.white
        if !(Radioplayer.sharedInstance.currentlyPLaying()) {
            buttomBar.isHidden = true
        } else {
            
            pauseButton.isEnabled = true
            playButton.isEnabled = false
        }
        
        //Long Tap Guesture for add to fav
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addToFav))
        longPressGesture.minimumPressDuration = 0.5
        // longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
        
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
                self.activityIndicator.stopAnimating()
            } else {
                print(msg)
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
                self.activityIndicator.stopAnimating()
            } else {
                print(msg)
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
                self.activityIndicator.stopAnimating()
            } else {
                print(msg)
                self.activityIndicator.stopAnimating()
            }
        })
        
    }

    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return radioStations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as! StationsTableViewCell
        
        editCellView(cell: cell)
        
        cell.titleLabel.text = radioStations[indexPath.row].name
        if radioStations[indexPath.row].imgURL != "" {
            cell.bgImage.af_setImage(withURL: URL(string:radioStations[indexPath.row].imgURL)!)
        } else {
            cell.bgImage.image = #imageLiteral(resourceName: "radioAvatar")
        }
        
        loadedImageName = (radioStations[indexPath.row].country).lowercased() + ".png"
        cell.countryFlagImageView.image = UIImage(named: loadedImageName)
        
        cell.countryLabel.text = radioStations[indexPath.row].country
        cell.numberOfListeners.text = String(radioStations[indexPath.row].listeners)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Radioplayer.sharedInstance.pause()
        loadedImageName = (radioStations[indexPath.row].country).lowercased() + ".png"
        performSegue(withIdentifier: "radioDetail", sender: radioStations[indexPath.row])
    }
    
    
    /* override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     
     let addFavIcon = UITableViewRowAction(style: .normal, title: "Favorite") { (action,index) -> Void in
     
     
     }
     let iconImage = UIImageView(image: #imageLiteral(resourceName: "star"))
     iconImage.contentMode = .scaleAspectFill
     addFavIcon.backgroundColor = UIColor(patternImage: iconImage.image!)
     return [addFavIcon]
     } */
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    
    func editCellView(cell:StationsTableViewCell) {
        
        cell.bgImage.layer.cornerRadius = cell.bgImage.frame.width/2
        //cell.bgImage.layer.borderWidth = 1.5
        // cell.bgImage.layer.borderColor = UIColor(red:0.60, green:0.07, blue:0.71, alpha:1.0).cgColor
        cell.bgImage.clipsToBounds = true
        //        cell.barCategoryField.layer.cornerRadius = cell.barCategoryField.frame.width/2
        //        cell.barLogoImageView.layer.cornerRadius = cell.barLogoImageView.frame.width/2
        //        cell.barLogoImageView.layer.borderWidth = 2.0
        //        cell.barLogoImageView.layer.borderColor = UIColor.green.cgColor
        //        cell.barLogoImageView.clipsToBounds = true
        //        cell.barDescriptionField.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
    }
    
    
    func addToFav(longPressureGesture: UILongPressGestureRecognizer) {
        
        let p = longPressureGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressureGesture.state == UIGestureRecognizerState.began) {
            let stationName = radioStations[indexPath!.row].name
            let stationCountryCode = radioStations[indexPath!.row].country
            let stationStream = radioStations[indexPath!.row].streamURL
            let imageURL = radioStations[indexPath!.row].imgURL
            let stationCategory = radioStations[indexPath!.row].categoryTitle
            
            addFavToDB(name: stationName, category: stationCategory, avatarURL: imageURL, countryCode: stationCountryCode, streamURL: stationStream)
            
            // print("Long press on row, at \(indexPath!.row)")
            
        }
    }
    
    //Create context for CoreData
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    //Save station favorated to core data
    func addFavToDB(name:String, category:String, avatarURL: String, countryCode:String, streamURL: String) {
        
        let context = getContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Station", in: context)
        let station = Station(entity: entity!, insertInto: context)
        
        station.avatarUrl = avatarURL
        station.category = category
        station.countrycode = countryCode
        station.streamUrl = streamURL
        station.name = name
        
        //        trans.setValue(name, forKey: "name")
        //        trans.setValue(category, forKey: "category")
        //        trans.setValue(avatarURL, forKey: "avatarUrl")
        //        trans.setValue(countryCode, forKey: "countrycode")
        //        trans.setValue(streamURL, forKey: "streamUrl")
        
        do {
            try context.save()
            print("Saved")
        } catch let err as Error? {
            print("Error not saved:", err!)
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