//
//  ViewController.swift
//  NumberInputViewSample
//
//  Created by Lukes Lu on 2018/9/2.
//  Copyright © 2018 YunShenIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Property
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    
    // MARK: - Memory
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        
    }
    
    // MARK: - Actions
    
    @IBAction func whenOpenButtonTapped(_ sender: UIButton) {
        if let view = NumberInputView.instantiate() {
            view.valueRecall.delegate(on: self) { (self, value) in
                self.numberLabel.text = self.getString(with: value)
                self.tipsLabel.text = ""
            }
            view.tipsRecall.delegate(on: self) { (self, tips) in
                self.tipsLabel.text = tips
            }
            
            UIApplication.shared.delegate?.window??.addSubview(view)
        }
    }
    
    // MARK: - Methods
    
    private func getString(with value: Double) -> String {
        let str = "\(value)"
        if let range = str.range(of: ".") {
            let dig = "0.\(str[range.upperBound...])"
            if let num = Double.init(dig), num > 0 {
                return str
            }
        }
        
        return String(format: "%.0f", value)
    }
    
}
