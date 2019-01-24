//
//  ListTableView.swift
//  Reproductor
//
//  Created by Pablo on 31/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit
import AVFoundation

class ListTableView: UITableViewController {

    @IBOutlet var editButton: UIBarButtonItem!
    var listName : String = ""
    var musicLists = [String: [String]]()
    var listSongs : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listSongs = musicLists[listName]!
        
        navigationItem.title = listName
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return listSongs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)

        var labelTitle = ""
        var labelArtist = ""
        var imageAlbum = UIImage(named: "")
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let soundPathURL = documentsPath.appendingPathComponent(listSongs[indexPath.row])
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
    }*/

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            listSongs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            musicLists[listName] = listSongs
            UserDefaults.standard.set(musicLists, forKey: "lists")
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let song : String = listSongs.remove(at: fromIndexPath.row)
        listSongs.insert(song, at: to.row)
        musicLists[listName] = listSongs
        UserDefaults.standard.set(musicLists, forKey: "lists")
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        let res = (segue.source as! AddTableView).addMusic
        listSongs.append(contentsOf: res)
        musicLists[listName] = listSongs
        UserDefaults.standard.set(musicLists, forKey: "lists")
        tableView.reloadData()
    }
    
    @IBAction func toggleEdit(_ sender: Any) {
        if isEditing {
            setEditing(false, animated: true)
            editButton.title = "Editar"
        }
        else {
            setEditing(true, animated: true)
            editButton.title = "Hecho"
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detail" {
            let dest = segue.destination as! ViewController
            dest.pos = tableView.indexPathForSelectedRow!.row
            dest.music = listSongs
        }
    }
    
}
