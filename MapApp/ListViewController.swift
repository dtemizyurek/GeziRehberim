//
//  ListViewController.swift
//  MapApp
//
//  Created by Doğukan Temizyürek on 19.07.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYerİsmi = ""
    var secilenYerId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(artiButonuTiklandi))
    veriAL()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAL), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
    }
   @objc func veriAL()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false
        do
        {
            let sonuclar = try context.fetch(request)
            isimDizisi.removeAll(keepingCapacity: false)
            idDizisi.removeAll(keepingCapacity: false)
            
            if sonuclar.count > 0
            {
                for sonuc in sonuclar as! [NSManagedObject]
                {
                    if let isim=sonuc.value(forKey: "isim") as? String
                    {
                        isimDizisi.append(isim)
                    
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID
                    {
                            idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
            
        }catch
        {
            
        }
        
    }
    
    @objc func artiButonuTiklandi()
    {
        secilenYerİsmi = ""
        performSegue(withIdentifier: "toMapVC" , sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text=isimDizisi[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        secilenYerİsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC"
        {
            let destinationVC = segue.destination as! MapViewController
            destinationVC.secilenIsim = secilenYerİsmi
            destinationVC.secilenId = secilenYerId
        }
    }

   
}
