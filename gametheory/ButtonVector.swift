//
//  ButtonVector.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class SingleButtonVector:ButtonVector   {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.width, height: collectionView.frame.height)
    }
}

class HorizontalButtonVector:ButtonVector {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionView.frame.width-((numberOfButtons!-CGFloat(1.0))*1) - (numberOfButtons! * 1))/numberOfButtons!), height: collectionView.frame.height)
    }
}

class VerticalButtonVector:ButtonVector {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: ((collectionView.frame.height-((numberOfButtons!-CGFloat(1.0))*1) - (numberOfButtons! * 1))/numberOfButtons!))
    }
}

class ButtonVector:UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout   {
    
    let reuseIdentifier = "buttonCell"
    var numberOfButtons:CGFloat?
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int((numberOfButtons)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ButtonCell
        return cell
    }
    
    func removeAllOtherButtons()    {
        for cell in collectionView.visibleCells as! [ButtonCell] {
            cell.isUserInteractionEnabled = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ButtonCell:UICollectionViewCell {
    
    ///Indexpath of selected cell
    var selectedCell:IndexPath?
    
    let buttonView:UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = CGFloat(2.0)
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.cornerRadius = CGFloat(4.0)
        button.isUserInteractionEnabled = true
        button.clipsToBounds = true
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    override init(frame: CGRect)    {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews()   {
        addSubview(buttonView)
        addConstraintsWithFormat(format: "H:[v0(20)]", views: buttonView)
        addConstraintsWithFormat(format: "V:[v0(20)]", views: buttonView)
        addConstraint(NSLayoutConstraint(item: buttonView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        buttonView.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    }
    
    @objc func buttonTouched(sender:UIButton!)    {
        let cellView = sender.superview as! ButtonCell
        let cellCollectionView = superview?.superview as! ButtonVector
        selectedCell = cellCollectionView.collectionView.indexPath(for: cellView)
        removeOtherButtons(cell: cellView, cellVector:cellCollectionView)
    }
    
    func removeOtherButtons(cell: ButtonCell, cellVector: ButtonVector)   {
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            cellVector.removeAllOtherButtons()
            cell.buttonView.backgroundColor = UIColor.blue
        }, completion: nil)
        
        UIView.animate(withDuration: 0.55, animations: {
            cellVector.removeAllOtherButtons()
            cell.buttonView.backgroundColor = UIColor.blue
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
