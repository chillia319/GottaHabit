//
//  OnboardingVC.swift
//  HabitManager
//
//  Created by Percy Hu on 2/12/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//
import UIKit

class OnboardingVC: UIViewController {
    
    @IBOutlet var gotItButton: UIButton!
    
    override func viewDidLoad() {
        gotItButton.layer.cornerRadius = 15
        gotItButton.layer.borderWidth = 2
        gotItButton.layer.borderColor = UIColor.white.cgColor
        gotItButton.clipsToBounds = true
    }
    
    @IBAction func gotItPressed(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "firstTimeOpening")
        performSegue(withIdentifier: "OnboardingToMain", sender: self)
    }
}
