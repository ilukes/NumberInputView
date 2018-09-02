//
//  CurrencyInputView.swift
//  Todays Exchange Rate
//
//  Created by Lukes Lu on 2018/8/31.
//  Copyright © 2018 Lukes Lu. All rights reserved.
//

import UIKit

class NumberInputView: UIView {

    // MARK: - Public
    
    public static func instantiate() -> NumberInputView? {
        if let view = Bundle.main.loadNibNamed("NumberInputView", owner: self, options: nil)?[0] as? NumberInputView {
            view.frame = UIScreen.main.bounds
            return view
        }
        
        return nil
    }
    
    // MARK: - Property
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    
    var hideBackgroundClicked: Bool = true
    
    var valueRecall: NIVDelegate = NIVDelegate<Double, Void>()
    var tipsRecall: NIVDelegate = NIVDelegate<String, Void>()
    
    private var firstInputString: String = ""
    private var secondInputString: String = ""
    private var numberOperator: String = ""
    
    // MARK: - Setter/Getter
    
    var lineColor: UIColor = UIColor.init(red: 60/255.0, green: 61/255.0, blue: 63/255.0, alpha: 1.0) {
        didSet {
            self.updateLines(view: self)
        }
    }
    var lineWidth: CGFloat = 1.0/UIScreen.main.scale {
        didSet {
            self.updateLines(view: self)
        }
    }
    var areaColor: UIColor = .darkGray {
        didSet {
            self.backgroundImageView.backgroundColor = self.areaColor
        }
    }
    var wordColor: UIColor = .white {
        didSet {
            self.connection(view: self.mainView)
        }
    }
    
    
    // Lifecycle
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Init
        
        self.backgroundImageView.backgroundColor = self.areaColor
        self.updateLines(view: self)
        self.connection(view: self.mainView)
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: - Private Methods
    
    private func updateLines(view: UIView) {
        for sub in view.subviews {
            if sub.tag == -1 && sub.isKind(of: UIImageView.self) {
                for constraint in sub.constraints {
                    if constraint.constant <= 1.0 {
                        constraint.constant = self.lineWidth
                    }
                }
                sub.backgroundColor = self.lineColor
            }else if !sub.subviews.isEmpty {
                self.updateLines(view: sub)
            }
        }
    }
    
    private func connection(view: UIView) {
        for sub in view.subviews {
            if let btn = sub as? UIButton {
                btn.setTitleColor(self.wordColor, for: .normal)
                btn.addTarget(self, action: #selector(whenButtonTapped(_:)), for: .touchUpInside)
            }else if !sub.subviews.isEmpty {
                self.connection(view: sub)
            }
        }
    }
    
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
    
    // MARK: - Public Methods
    
    public func hide() {
        UIView.animate(withDuration: 0.35, animations: {
            self.mainView.frame = CGRect(x: self.mainView.frame.origin.x, y: self.bounds.height, width: self.mainView.bounds.width, height: self.mainView.bounds.height)
            self.backgroundImageView.frame = CGRect(x: self.backgroundImageView.frame.origin.x, y: self.bounds.height, width: self.backgroundImageView.bounds.width, height: self.backgroundImageView.bounds.height)
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func whenBackgroundButtonTapped(_ sender: UIButton) {
        if self.hideBackgroundClicked {
            self.hide()
        }
    }
    
    @objc private func whenButtonTapped(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            switch title {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                if self.numberOperator.isEmpty {
                    if title == "0", self.firstInputString == "0" {
                    }else{
                        self.firstInputString = "\(self.firstInputString)\(title)"
                    }
                    
                    if let value = Double.init(self.firstInputString) {
                        self.valueRecall.call(value)
                    }
                }else{
                    if title == "0", self.secondInputString == "0" {
                    }else{
                        self.secondInputString = "\(self.secondInputString)\(title)"
                    }
                    
                    if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                        self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)\(self.getString(with: second))")
                    }
                }
            case "–":
                if self.numberOperator.isEmpty {
                    self.numberOperator = "–"
                    if self.firstInputString.isEmpty {
                        self.firstInputString = "0"
                    }
                    
                    if let first = Double.init(self.firstInputString) {
                        self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                    }
                }else{
                    switch self.numberOperator {
                    case "–":
                        if self.secondInputString.isEmpty {
                            if let first = Double.init(self.firstInputString) {
                                self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                            }
                        }else{
                            if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                                let value = first-second
                                
                                self.firstInputString = self.getString(with: value)
                                
                                self.valueRecall.call(value)
                                self.tipsRecall.call("\(self.getString(with: value))\(self.numberOperator)")
                            }
                        }
                    case "+":
                        if self.secondInputString.isEmpty {
                            self.numberOperator = "–"
                            if let first = Double.init(self.firstInputString) {
                                self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                            }
                        }else{
                            if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                                let value = first+second
                                
                                self.numberOperator = "–"
                                self.firstInputString = self.getString(with: value)
                                
                                self.valueRecall.call(value)
                                self.tipsRecall.call("\(self.getString(with: value))\(self.numberOperator)")
                            }
                        }
                    default:
                        break
                    }
                }
                
                self.secondInputString = ""
                self.okButton.setTitle("=", for: .normal)
            case "+":
                if self.numberOperator.isEmpty {
                    self.numberOperator = "+"
                    if self.firstInputString.isEmpty {
                        self.firstInputString = "0"
                    }
                    
                    if let first = Double.init(self.firstInputString) {
                        self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                    }
                }else{
                    switch self.numberOperator {
                    case "–":
                        if self.secondInputString.isEmpty {
                            self.numberOperator = "+"
                            if let first = Double.init(self.firstInputString) {
                                self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                            }
                        }else {
                            if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                                let value = first-second
                                
                                self.numberOperator = "+"
                                self.firstInputString = self.getString(with: value)
                                
                                self.valueRecall.call(value)
                                self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                            }
                        }
                    case "+":
                        if self.secondInputString.isEmpty {
                            if let first = Double.init(self.firstInputString) {
                                self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                            }
                        }else{
                            if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                                let value = first+second
                                
                                self.firstInputString = self.getString(with: value)
                                
                                self.valueRecall.call(value)
                                self.tipsRecall.call("\(self.getString(with: value))\(self.numberOperator)")
                            }
                        }
                    default:
                        break
                    }
                }
                
                self.secondInputString = ""
                self.okButton.setTitle("=", for: .normal)
            case ".":
                if self.numberOperator.isEmpty {
                    if let _ = self.firstInputString.range(of: ".") {
                        
                    }else{
                        self.firstInputString = "\(self.firstInputString)."
                        if let first = Double.init(self.firstInputString) {
                            self.valueRecall.call(first)
                        }
                    }
                }else{
                    if let _ = self.secondInputString.range(of: ".") {
                        
                    }else{
                        self.secondInputString = "\(self.secondInputString)."
                        if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                            self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)\(self.getString(with: second))")
                        }
                    }
                }
            case "C":
                if self.numberOperator.isEmpty {
                    self.firstInputString = ""
                    self.valueRecall.call(0)
                }else{
                    self.secondInputString = ""
                    
                    if let first = Double.init(self.firstInputString) {
                        self.tipsRecall.call("\(self.getString(with: first))\(self.numberOperator)")
                    }
                }
            case "=":
                if self.secondInputString.isEmpty {
                    self.secondInputString = "0"
                }
                switch self.numberOperator {
                case "–":
                    if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                        let value = first-second
                        
                        self.valueRecall.call(value)
                        self.firstInputString = self.getString(with: value)
                        self.tipsRecall.call("")
                    }
                case "+":
                    if let first = Double.init(self.firstInputString), let second = Double.init(self.secondInputString) {
                        let value = first+second
                        
                        self.valueRecall.call(value)
                        self.firstInputString = self.getString(with: value)
                        self.tipsRecall.call("")
                    }
                default:
                    break
                }
                
                self.numberOperator = ""
                self.secondInputString = ""
                self.okButton.setTitle("OK", for: .normal)
            case "OK":
                self.hide()
            default:
                break
            }
        }
    }
    
}

class NIVDelegate<Input, Output> {
    
    private var block: ((Input) -> Output?)?
    
    func delegate<T:AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        self.block = {[weak target] input in
            guard let target = target else {
                return nil
            }
            return block?(target, input)
        }
    }
    
    func call(_ input: Input) -> Output? {
        return block?(input)
    }
    
}

extension NIVDelegate where Input == Void {
    func call() -> Output? {
        return call(())
    }
}

