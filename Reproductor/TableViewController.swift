//
//  TableViewController.swift
//  Reproductor
//
//  Created by Pablo on 28/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewController: UITableViewController {

    var allMusic : [String] = []
    var musicLists = [String: [String]]()
    var lists : [String] = []
    @IBOutlet var editButton: UIBarButtonItem!
    
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
        
        // Se almacena una lista con los nombres de las listas de canciones
        if UserDefaults.standard.object(forKey: "keyList") != nil {
            lists = UserDefaults.standard.object(forKey: "keyList") as! [String]
        } else {
            UserDefaults.standard.set(lists, forKey: "keyList")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        // Se almacena un diccionario con el nombre de las listas y sus canciones
        if UserDefaults.standard.object(forKey: "lists") != nil {
            musicLists = UserDefaults.standard.object(forKey: "lists") as! [String: [String]]
        } else {
            UserDefaults.standard.set(musicLists, forKey: "lists")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if section == 0 {
            return allMusic.count
        } else {
            return lists.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Canciones"
        } else {
            return "Listas de reproducción"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.section == 0 {
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
        } else {
            let listName = lists[indexPath.row]
            cell.textLabel?.text = listName
            let numSongs = musicLists[listName]!.count
            if numSongs == 1 {
                cell.detailTextLabel?.text = "\(String(numSongs)) canción"
            } else {
                cell.detailTextLabel?.text = "\(String(numSongs)) canciones"
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "detail", sender: self)
        } else {
            self.performSegue(withIdentifier: "list", sender: self)
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let listName = lists.remove(at: indexPath.row)
            UserDefaults.standard.set(lists, forKey: "keyList")
            
            musicLists[listName] = nil
            UserDefaults.standard.set(musicLists, forKey: "lists")
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
    
    @IBAction func addList(_ sender: Any) {
        let alert = UIAlertController(title: "Añadir lista de reproducción", message: "Introduzca el nombre de la lista", preferredStyle: .alert)
        
        alert.addTextField { textField -> Void in
            textField.placeholder = "Nombre"
        }
        
        let action = UIAlertAction(title: "Añadir", style: .default, handler: { action in
            let listName = alert.textFields![0].text!
            if self.lists.contains(listName) {
                let alertExist = UIAlertController(title: "Error", message: "El nombre ya existe", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                alertExist.addAction(ok)
                self.present(alertExist, animated: true)
            } else {
                self.lists.append(listName)
                self.tableView.reloadData()
                UserDefaults.standard.set(self.lists, forKey: "keyList")
                self.musicLists[listName] = []
                UserDefaults.standard.set(self.musicLists, forKey: "lists")
            }
        })
        let cancel = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let pos = tableView.indexPathForSelectedRow?.row
        if segue.identifier == "detail" {
            let dest = segue.destination as! ViewController
            dest.pos = pos!
        } else {
            let dest = segue.destination as! ListTableView
            let listName = lists[pos!]
            dest.listName = listName
            dest.musicLists = musicLists
        }
    }
}
