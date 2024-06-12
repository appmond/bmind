//
//  PayoffMatrix.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class BigPayoffMatrix:PayoffMatrix {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfEntriesInPayoffArray = Double((payoffMatrix?.count)!)
        let tmpdimension = (Double(120)/sqrt(noOfEntriesInPayoffArray))
        return CGSize(width: tmpdimension, height: tmpdimension)
    }
}

class SmallSecondPayoffMatrix:PayoffMatrix    {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfEntriesInPayoffArray = Double((payoffMatrix?.count)!)
        let tmpdimension = (Double(90)/sqrt(noOfEntriesInPayoffArray))
        return CGSize(width: tmpdimension, height: tmpdimension)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MatrixCell
        cell.labelView.text = "\(payoffMatrix![indexPath.item])"
        cell.labelView.textColor = UIColor.green
        return cell
    }
}

class SmallFirstPayoffMatrix:PayoffMatrix    {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfEntriesInPayoffArray = Double((payoffMatrix?.count)!)
        let tmpdimension = (Double(90)/sqrt(noOfEntriesInPayoffArray))
        return CGSize(width: tmpdimension, height: tmpdimension)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MatrixCell
        cell.labelView.text = "\(payoffMatrix![indexPath.item])"
        cell.labelView.textColor = UIColor.blue
        return cell
    }
}

class TwoPlayerPlayerTwoPayoffMatrix:PayoffMatrix {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MatrixCell
        let noOfEntriesInPayoffArray = Double((payoffMatrix?.count)!)
        let cellsInARow = sqrt(noOfEntriesInPayoffArray)
        cell.labelView.text = "\(payoffMatrix![indexPath.item])"
        cell.changePlayerTwoColor(indexPath: indexPath, cellsInARow: cellsInARow)
        cell.changeFont(cellsInARow: cellsInARow)
        return cell
    }
}

class TwoPlayerPlayerOnePayoffMatrix:PayoffMatrix {
    var rowIndex = 0.0
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MatrixCell
        let noOfEntriesInPayoffArray = Double((payoffMatrix?.count)!)
        let cellsInARow = sqrt(noOfEntriesInPayoffArray)
        cell.labelView.text = "\(payoffMatrix![indexPath.item])"
        rowIndex += (1/cellsInARow)
        cell.changePlayerOneColor(rowIndex: rowIndex)
        cell.changeFont(cellsInARow: cellsInARow)
        return cell
    }
}

class PayoffMatrix:UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout   {
    
    let reuseIdentifier = "matrixCell"
    var payoffMatrix:[Int]?
    
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
        collectionView.register(MatrixCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfEntriesInPayoffArray = Double((payoffMatrix?.count)!)
        let tmpdimension = (Double(200)/sqrt(noOfEntriesInPayoffArray))
        return CGSize(width: tmpdimension, height: tmpdimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (payoffMatrix?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MatrixCell
        cell.labelView.text = "\(payoffMatrix![indexPath.item])"
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MatrixCell:UICollectionViewCell {
    
    let labelView : UILabel = {
        let lv = UILabel()
        lv.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)
        lv.textAlignment = .center
        lv.backgroundColor = UIColor.clear
        return lv
    }()
    
    func changePlayerOneColor(rowIndex:Double) {
        if rowIndex <= 1 {
            self.labelView.textColor = UIColor.init(red: 188, green: 122, blue: 0, alpha: 1)
        } else if rowIndex <= 2  {
            self.labelView.textColor = UIColor.init(red: 0, green: 255, blue: 255, alpha: 1)
        } else if rowIndex <= 3   {
            self.labelView.textColor = UIColor.blue
        } else if rowIndex <= 3 {
            self.labelView.textColor = UIColor.init(red: 255, green: 0, blue: 170, alpha: 1)
        } else if rowIndex <= 4 {
            self.labelView.textColor = UIColor.red
        } else {
            self.labelView.textColor = UIColor.brown
        }
    }
    
    func changePlayerTwoColor(indexPath:IndexPath, cellsInARow:Double) {
        if (indexPath.item%Int(cellsInARow)) == 0 {
            labelView.textColor = UIColor.init(red: 188, green: 122, blue: 0, alpha: 1)
        } else if (indexPath.item%Int(cellsInARow)) == 1   {
            self.labelView.textColor = UIColor.init(red: 0, green: 255, blue: 255, alpha: 1)
        } else if (indexPath.item%Int(cellsInARow)) == 2   {
            self.labelView.textColor = UIColor.blue
        } else if (indexPath.item%Int(cellsInARow)) == 3    {
            self.labelView.textColor = UIColor.init(red: 255, green: 0, blue: 170, alpha: 1)
        } else if (indexPath.item%Int(cellsInARow)) == 4   {
            self.labelView.textColor = UIColor.red
        } else  {
            self.labelView.textColor = UIColor.brown
        }
    }
    
    func setupViews()   {
        addSubview(labelView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: labelView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: labelView)
        addConstraint(NSLayoutConstraint(item: labelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: labelView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func changeFont(cellsInARow:Double)   {
        if Int(cellsInARow) < 3 {
            self.labelView.font = UIFont(name: "HelveticaNeue-Bold", size: 24.0)
        } else if Int(cellsInARow) < 5  {
            self.labelView.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
        } else{
            self.labelView.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)
        }
    }
    
    override init(frame: CGRect)    {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
