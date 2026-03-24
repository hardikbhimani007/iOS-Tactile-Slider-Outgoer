//
//  ViewController.swift
//  TactileSlider
//
//  Created by daprice on 01/22/2019.
//  Copyright (c) 2019 daprice. All rights reserved.
//

import UIKit
import TactileSlider

class ViewController: UIViewController {
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		if #available(iOS 13, *) {
			self.view.backgroundColor = UIColor.systemBackground
		} else {
			self.view.backgroundColor = UIColor.white
		}
        
        applyPurpleCyanGradientToSliders(in: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func applyPurpleCyanGradientToSliders(in root: UIView) {
        for subview in root.subviews {
            if let slider = subview as? TactileSlider {
                slider.gradientTintColors = [
                    UIColor(hex: "#D478FF")!,
                    UIColor(hex: "#46D3FF")!
                ]
                slider.tintColor = UIColor(hex: "#D478FF")!
            }
            applyPurpleCyanGradientToSliders(in: subview)
        }
    }

}

