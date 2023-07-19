//
//  ViewController.swift
//  MapApp
//
//  Created by Doğukan Temizyürek on 19.07.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var isimTextField: UITextField!
    
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 3 //minimum basma süresi
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim != ""
        //CoreDatadan verileri çek
        {
            if let uuidString = secilenId?.uuidString
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0
                    {
                        for sonuc in sonuclar as! [NSManagedObject]
                        {
                            if let isim = sonuc.value(forKey: "isim") as? String
                            {
                                annotationTitle = isim
                                if let not = sonuc.value(forKey: "not") as? String
                                {
                                    annotationSubtitle = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double
                                    {
                                        annotationLatitude = latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double
                                        {
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            
                                            isimTextField.text = annotationTitle
                                            notTextField.text = annotationSubtitle
                                            
                                            
                                            locationManager.stopUpdatingLocation()
                                            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            
                                            mapView.setRegion(region, animated: true)

                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }catch
                {
                    print("hata")
                }

                
            }
            
        }
        else
        {
            //yeni veri eklemeye geldi
        }
    
    }
    
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == .began //Jest algılayıcının durumunu anlatan kod parçası (başlaması , bitmesi vb)
        {
            let dokunulanNokta =  gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta,toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate=dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      //  print(locations[0].coordinate.latitude)
      //  print(locations[0].coordinate.longitude)
        if secilenIsim == ""
        {
                let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            
                let region = MKCoordinateRegion(center: location, span: span)
            
            
                mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func KaydetTiklandi(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniyer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniyer.setValue(isimTextField.text, forKey: "isim")
        yeniyer.setValue(notTextField.text, forKey: "not")
        yeniyer.setValue(secilenLatitude, forKey: "latitude")
        yeniyer.setValue(secilenLongitude, forKey: "longitude")
        yeniyer.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Kayıt Edildi")
        }catch{
            print("hata")
        }
        NotificationCenter.default.post(name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation
        {
            return nil
        }
        let reuseId = "benimAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil
        {
        
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .orange
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else
        {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
    if secilenIsim != ""
        {
        var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
        
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placeMarkDizisi, hata) in
            if let placemarks = placeMarkDizisi
            {
                
                if placemarks.count > 0
                {
                    let yeniPlaceMark = MKPlacemark(placemark: placemarks[0])
                    let item = MKMapItem(placemark: yeniPlaceMark)
                    item.name = self.annotationTitle
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    
                    item.openInMaps(launchOptions: launchOptions)
                    
                    
                }
            }
            
        }
        
    }
        
        
    }
    
}

