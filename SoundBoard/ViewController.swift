//
//  ViewController.swift
//  SoundBoard
//
//  Created by Yesica Rojas on 11/5/23.
//  Copyright © 2023 deah. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    var volumen: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MiCeldaConDetalle")
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        cell.detailTextLabel?.text = formatearTiempo(grabacion.duracion)
        
        let slider = UISlider(frame: CGRect(x: 10, y: 10, width: 200, height: 30))
        slider.value = grabacion.volumen
        slider.tag = indexPath.row
        slider.addTarget(self, action: #selector(ajustarVolumen(_:)), for: .valueChanged);
        cell.accessoryView = slider
        return cell
    }
    
    @objc func ajustarVolumen(_ sender: UISlider) {
        let grabacion = grabaciones[sender.tag]
        grabacion.volumen = sender.value
    }

    
    func formatearTiempo(_ tiempo: TimeInterval) ->String {
        let minutos = Int(tiempo) / 60
        let segundos = Int(tiempo) % 60
        return String(format: "%2d:%02d", minutos, segundos)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let grabacion = grabaciones[indexPath.row]
        do{
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.volume = grabacion.volumen
            reproducirAudio?.play()
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            }catch{}
        }
    }

}

