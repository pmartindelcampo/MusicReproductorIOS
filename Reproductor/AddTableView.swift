//
//  AddTableView.swift
//  Reproductor
//
//  Created by Pablo on 01/01/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import UIKit
import AVFoundation

class AddTableView: UITableViewController {

    var allMusic : [String] = []
    var addMusic : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(documentsPath.path)
        
        let fm = FileManager.default
        let allFiles = try! fm.contentsOfDirectory(atPath: documentsPath.path)
        
        for file in allFiles {
            if file.contains(".mp3") {
                allMusic.append(file)
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return allMusic.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType != .checkmark {
                cell.accessoryType = .checkmark
                addMusic.append(allMusic[indexPath.row])
            } else {
                cell.accessoryType = .none
                addMusic.removeAll(where: { $0 == allMusic[indexPath.row] })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var labelTitle = ""
        var labelArtist = ""
        var imageAlbum = UIImage(named: "")
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let soundPathURL = documentsPath.appendingPathComponent(allMusic[indexPath.row])
        let playerItem = AVPlayerItem(url: soundPathURL)
        let metadataList = playerItem.asset.commonMetadata
        for item in metadataList {
            if item.commonKey == nil {
                continue
            }
            
            if let key = item.commonKey?.rawValue, let value = item.value {
                switch key {
                case "title":
                    print(value)
                    labelTitle = (value as? String)!
                case "artist":
                    print(value)
                    labelArtist = (value as? String)!
                case "artwork" where value is Data:
                    imageAlbum = UIImage(data: value as! Data)
                default:
                    continue
                }
            }
        }
        
        // Configure the cell...
        cell.textLabel?.text = labelTitle
        cell.detailTextLabel?.text = labelArtist
        cell.imageView?.image = imageAlbum

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func volver(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
