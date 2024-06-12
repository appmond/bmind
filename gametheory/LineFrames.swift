//
//  LineFrames.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class BaseLineFrame:UIView {
    
    let lineFrame : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.black
        return line
    }()
    
    override init(frame: CGRect)    {
        super.init(frame: frame)
        setupLines()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLines()   {}
    
    func divideGridView(tempMatrixView: UIView, numberOfRowsAndColumns:CGFloat){
        let sideLength = tempMatrixView.bounds.width
        let matrixWithoutFrames = sideLength - (5 * (numberOfRowsAndColumns - 1))
        var counter = matrixWithoutFrames/numberOfRowsAndColumns
        let tmpCounter = counter
        
        while (counter < sideLength - CGFloat(FLT_EPSILON)) {
            let hLine = HorizontalLineFrame()
            tempMatrixView.addSubview(hLine)
            tempMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: hLine)
            tempMatrixView.addConstraintsWithFormat(format: "V:|-\(counter)-[v0]", views: hLine)
            
            let vLine = VerticalLineFrame()
            
            tempMatrixView.addSubview(vLine)
            tempMatrixView.addConstraintsWithFormat(format: "H:|-\(counter)-[v0]", views: vLine)
            tempMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: vLine)
            
            counter = counter + tmpCounter + 5
            
        }
        
    }
    
}

class HorizontalLineFrame:BaseLineFrame    {

    override func setupLines() {
        addSubview(super.lineFrame)
        addConstraintsWithFormat(format: "H:|[v0]|", views: super.lineFrame)
        addConstraintsWithFormat(format: "V:|[v0(2)]", views: super.lineFrame)
    }
    
}

class VerticalLineFrame:BaseLineFrame  {
    
    override func setupLines() {
        addSubview(super.lineFrame)
        addConstraintsWithFormat(format: "H:|[v0(2)]", views: super.lineFrame)
        addConstraintsWithFormat(format: "V:|[v0]|", views: super.lineFrame)
    }
}
