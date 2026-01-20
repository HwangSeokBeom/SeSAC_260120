//
//  ViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var oneButton: UIButton!
    @IBOutlet var twoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func oneButtonClicked(_ sender: UIButton) {
        let picsumVC = PicsumViewController()
        navigationController?.pushViewController(picsumVC, animated: true)
    }
    
    @IBAction func twoButtonClicked(_ sender: UIButton) {
        let movieVC = MovieViewController()
        navigationController?.pushViewController(movieVC, animated: true)
    }
}

