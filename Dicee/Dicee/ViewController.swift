//
//  ViewController.swift
//  Dicee-iOS13
//
//  Created by Angela Yu on 11/06/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let diceInfor = [#imageLiteral(resourceName: "DiceOne"), #imageLiteral(resourceName: "DiceTwo"), #imageLiteral(resourceName: "DiceThree"), #imageLiteral(resourceName: "DiceFour"), #imageLiteral(resourceName: "DiceFive"), #imageLiteral(resourceName: "DiceSix")]
    var spinCount = 0

    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var diceImageView1: UIImageView!
    @IBOutlet weak var diceImageView2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rollButton.layer.cornerRadius = 10
    }

    @IBAction func rollButtonPressed(_ sender: UIButton) {
//        diceImageView1.image = diceInfor[Int.random(in: 0...5)]
//        diceImageView2.image = diceInfor[Int.random(in: 0...5)]
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.spinCount+=1
            self.spinCount%=2
            let rotateMultiple = CGFloat(self.spinCount)
            self.diceImageView1.transform = CGAffineTransform(rotationAngle: .pi*rotateMultiple)
            self.diceImageView2.transform = CGAffineTransform(rotationAngle: .pi*rotateMultiple)
        }, completion: {finished in
            self.diceImageView1.image = self.diceInfor.randomElement()
            self.diceImageView2.image = self.diceInfor[Int.random(in: 0...5)]
            // 이렇게 random 으로 할수 있음 !

        })
       
    }
}


