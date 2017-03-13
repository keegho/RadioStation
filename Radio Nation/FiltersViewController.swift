//
//  FiltersViewController.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/12/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit
import SwiftyJSON

class FiltersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var categoryTextfield: UITextField!
    @IBOutlet var countryTextField: UITextField!
    
    var pickerCountry = UIPickerView()
    var pickerCategory = UIPickerView()
    
    let radioStation = Radiostation()
    

    var pickerCountries = ["All"]
    var selectedCountryCode = String()
    var countryCodes = ["aa"]
    var categoryIDs = [0]
    var selectedCategoryID = Int()

    var pickerCategories = ["All"]
    var flagsNamesArray = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Filters"
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        //Create Country picker view
   
        pickerCountry = UIPickerView(frame: CGRect(x:0, y:200, width:view.frame.width, height:300))
        pickerCountry.backgroundColor = UIColor.white
        pickerCountry.tag = 0
        
        pickerCountry.showsSelectionIndicator = true
        pickerCountry.delegate = self
        pickerCountry.dataSource = self
        
        let toolBarCountry = UIToolbar()
        toolBarCountry.barStyle = UIBarStyle.default
        toolBarCountry.isTranslucent = true
        toolBarCountry.tintColor = UIColor.white
        toolBarCountry.backgroundColor = UIColor(red:0.71, green:0.22, blue:0.22, alpha:1.0)
        toolBarCountry.alpha = 0.5
        toolBarCountry.sizeToFit()
        
        let doneButtonCountry = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneCountryPicker))
        let spaceButtonCountry = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //  let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBarCountry.setItems([/*cancelButton,*/ spaceButtonCountry, doneButtonCountry], animated: false)
        toolBarCountry.isUserInteractionEnabled = true
        
        countryTextField.inputView = pickerCountry
        countryTextField.inputAccessoryView = toolBarCountry
        
        //Get image files names as url
        let f = Bundle.main.url(forResource: "Flags", withExtension: nil)!
        let fm = FileManager()
        flagsNamesArray = try! fm.contentsOfDirectory(at: f, includingPropertiesForKeys: nil, options: [])
       // print(flagsNamesArray) // the URLs of the two jpg files
        
        
        //Create Category picker view
        
        pickerCategory = UIPickerView(frame: CGRect(x:0, y:200, width:view.frame.width, height:300))
        pickerCategory.backgroundColor = UIColor(red:0.71, green:0.22, blue:0.22, alpha:1.0)
        pickerCategory.tag = 1
        
        pickerCategory.showsSelectionIndicator = true
        pickerCategory.delegate = self
        pickerCategory.dataSource = self
        
        let toolBarCategory = UIToolbar()
        toolBarCategory.barStyle = UIBarStyle.default
        toolBarCategory.isTranslucent = true
        toolBarCategory.tintColor = UIColor.white
        toolBarCategory.backgroundColor = UIColor(red:0.71, green:0.22, blue:0.22, alpha:1.0)
        toolBarCategory.alpha = 0.5
        toolBarCategory.sizeToFit()
        
        let doneButtonCategory = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneCategoryPicker))
        let spaceButtonCategory = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //  let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBarCategory.setItems([/*cancelButton,*/ spaceButtonCategory, doneButtonCategory], animated: false)
        toolBarCategory.isUserInteractionEnabled = true
        
        categoryTextfield.inputView = pickerCategory
        categoryTextfield.inputAccessoryView = toolBarCategory
        
        loadData()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        
        //Draw text field with only down boarder
        let borderCountry = CALayer()
        let borderCategory = CALayer()
        let width = CGFloat(0.7)
        borderCountry.borderColor = UIColor.lightGray.cgColor
        borderCountry.frame = CGRect(x: 0, y: countryTextField.frame.size.height - width, width:  countryTextField.frame.size.width, height: countryTextField.frame.size.height)
        
        borderCategory.borderColor = UIColor.lightGray.cgColor
        borderCategory.frame = CGRect(x: 0, y: categoryTextfield.frame.size.height - width, width:  categoryTextfield.frame.size.width, height: categoryTextfield.frame.size.height)

        
        borderCountry.borderWidth = width
        borderCategory.borderWidth = width
        countryTextField.layer.addSublayer(borderCountry)
        countryTextField.layer.masksToBounds = true
        countryTextField.layer.addSublayer(borderCategory)
        countryTextField.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        
        radioStation.categories { (data, status, err, msg) in
            
            if status {
                let swiftyJSON = JSON(data)

                guard let categoryData = swiftyJSON.array else {
                    print("NOT AN ARRAY")
                    return
                }
                for category in categoryData {
                    guard let title = category["title"].string else {
                        return
                    }
                    self.pickerCategories.append(title)
                    
                    guard let id = category["id"].int else {
                        return
                    }
                    self.categoryIDs.append(id)
                }
               // print(self.categoryIDs)
            } else {
                
                print(msg)
            }
        }
        
        radioStation.countries { (data, status, err, msg) in
            
            if status {
                let swiftyJSON = JSON(data)
               // print(swiftyJSON)
                guard let countryData = swiftyJSON.array else {
                    print("NOT AN ARRAY")
                    return
                }
                for country in countryData {
                    guard let name = country["name"].string else {
                        return
                    }
                    self.pickerCountries.append(name)
                    
                    guard let code = country["country_code"].string else {
                        return
                    }
                    self.countryCodes.append(code)
                   // print(name); print(code)
                }
              //  print(self.countryCodes)
                
            } else {
                print(msg)
            }
        }
    }
    
    @IBAction func filterAction(_ sender: UIButton) {
        
        if !(categoryTextfield.text?.isEmpty)! && !(countryTextField.text?.isEmpty)! {
            performSegue(withIdentifier: "filtered", sender: nil)
        }
    }
    
    func doneCountryPicker() {
        countryTextField.resignFirstResponder()
        //pickerCountry.isHidden = true
    }
    
    func doneCategoryPicker() {
        categoryTextfield.resignFirstResponder()
       // pickerCategory.isHidden = true
    }
    
    
    //MARK: - Picker View DataSource
    
//   func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//       let titleData = pickerCategories[row]
//       let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
//        return myTitle
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return pickerCountries.count
        } else {
            return pickerCategories.count
        }
    }

    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return pickerCountries[row]
        } else {
            return pickerCategories[row]
        }
    
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let editedView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 60))
        
        if pickerView.tag == 0 {
            
            let countryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            countryImageView.contentMode = .center
            let nameLabel = UILabel(frame: CGRect(x: 60, y: 0, width: pickerView.bounds.width - 90, height: 60))
            let countryName = pickerCountries[row]
            
            //Invisible country code just for refrence
            selectedCountryCode = countryCodes[row]
            
            countryImageView.image = UIImage(named: String(describing: flagsNamesArray[row].lastPathComponent))
            
            nameLabel.text = countryName
            
            editedView.addSubview(nameLabel)
            editedView.addSubview(countryImageView)
            
            
        } else {
           // editedView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 60))
            let nameLabel = UILabel(frame: CGRect(x: 60, y: 0, width: pickerView.bounds.width - 90, height: 60))
            let categoryName = pickerCategories[row]
            
            //Invisible category id just for refrence
            selectedCategoryID = categoryIDs[row]
            
            nameLabel.text = categoryName
            editedView.addSubview(nameLabel)
        }
        return editedView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            countryTextField.text = pickerCountries[row]
        } else {
            categoryTextfield.text = pickerCategories[row]
        }
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "filtered" {
            guard let stationsVC = segue.destination as? StationsTableViewController else {
                return
            }
            stationsVC.filteredCategory = categoryTextfield.text!
            stationsVC.filteredCountry = countryTextField.text!
            stationsVC.filteredCountryCode = selectedCountryCode
            stationsVC.filteredCategoryID = selectedCategoryID
            
        }
    }
    

}
