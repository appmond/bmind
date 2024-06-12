//
//  GameTypesCell.swift
//  gametheory
//
//  Created by Edmond Osmani on 19/01/17.
//  Copyright © 2017 Edmond Osmani. All rights reserved.
//

import UIKit

class GameTypesCell : UICollectionViewCell    {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    
    override init(frame: CGRect)    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
