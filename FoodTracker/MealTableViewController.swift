//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Javier Portaluppi on 15/11/2019.
//  Copyright © 2019 Javier Portaluppi. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    static let MealsURL = "https://www.mocky.io/v2/5dd2c5b63300004e007a3e5b"
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } else {
            loadSampleMeals()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            cellIdentifier, for: indexPath) as? MealTableViewCell else {
                fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: Private Methods
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1,
                               rating: 4, photoUrl: nil) else {
                                fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2,
                               rating: 5, photoUrl: nil) else {
                                fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3,
                               rating: 3, photoUrl: nil) else {
                                fatalError("Unable to instantiate meal2")
        }
        meals += [meal1, meal2, meal3]
    }
    
    fileprivate func addMeal(_ meal: Meal) {
        // Add a new meal.
        let newIndexPath = IndexPath(row: meals.count, section: 0)
        meals.append(meal)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController,
            let meal = sourceViewController.meal {
            addMeal(meal)
            saveMeals()
        }
    }
    
    private func saveMeals() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: meals, requiringSecureCoding: false)
            try data.write(to: Meal.ArchiveURL)
            os_log("Meals successfully saved.", log: OSLog.default, type:
                .debug)
        } catch {
            os_log("Failed to save meals...", log: OSLog.default, type:
                .error)
        }
    }
    
    private func loadMeals() -> [Meal]? {
        do {
            let codedData = try Data(contentsOf: Meal.ArchiveURL)
            let meals = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as? [Meal]
            os_log("Meals successfully loaded.", log: OSLog.default, type: .debug)
            return meals;
        } catch {
            os_log("Failed to load meals...", log: OSLog.default, type: .error)
            return nil
        }
    }
    
    @IBAction func downloadAction(_ sender: UIBarButtonItem) {
        guard let url = URL(string: MealTableViewController.MealsURL) else {
            os_log("Invalid URL.", log: OSLog.default, type: .error)
            return
        }
        
        // download meals list from network
        URLSession(configuration: .default).dataTask(with: url) {
            (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                do {
                    // parse json to [Meal]
                    let newMeals: [Meal] = try JSONDecoder().decode([Meal].self, from: data)
                    
                    for meal in newMeals {
                        if let photoURL = meal.photoUrl {
                            
                            // download meal’s photo
                            URLSession(configuration: .default).dataTask(with: photoURL) {
                                (data, response, error) in
                                
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if
                                    let data = data,
                                    let response = response as? HTTPURLResponse,
                                    response.statusCode == 200 {
                                    
                                    meal.photo = UIImage(data: data)
                                }
                                
                                // add downloaded meal with photo
                                DispatchQueue.main.async {
                                    self.addMeal(meal)
                                }
                            }.resume()
                        } else {
                            // add downloaded meal without photo
                            DispatchQueue.main.async {
                                self.addMeal(meal)
                            }
                        }
                    }
                } catch let parseError as NSError {
                    print(parseError.localizedDescription)
                }
            }
        }.resume()
    }
    
}
