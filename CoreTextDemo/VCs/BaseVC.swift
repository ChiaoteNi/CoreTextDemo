//
//  BaseVC.swift
//  CoreTextDemo
//
//  Created by Chiao-Te Ni on 2018/9/13.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    var closeBtn: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBtn.setTitle("", for: .normal)
        closeBtn.setImage(#imageLiteral(resourceName: "closeBtn"), for: .normal)
        closeBtn.frame = CGRect(x: UIScreen.main.bounds.width - 30, y: 30, width: 20, height: 20)
        closeBtn.addTarget(self, action: #selector(close), for: UIControlEvents.allEvents)
        view.insertSubview(closeBtn, at: 0)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
