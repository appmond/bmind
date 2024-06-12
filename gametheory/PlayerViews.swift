//
//  PlayerView.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class SmallPlayerOneView:PlayerView {
    
    override init() {
        super.init()
        buttonVector = VerticalButtonVector()
        payOffMatrix = SmallFirstPayoffMatrix()
    }
}

class SmallPlayerTwoView:PlayerView{
    
    override init() {
        super.init()
        buttonVector = HorizontalButtonVector()
        payOffMatrix = SmallSecondPayoffMatrix()
    }
}

class BigPlayerView:PlayerView  {
    
    override init() {
        super.init()
        buttonVector = SingleButtonVector()
        payOffMatrix = BigPayoffMatrix()
    }
}

class PlayerOneView:PlayerView {
    
    override init()   {
        super.init()
        buttonVector = VerticalButtonVector()
        payOffMatrix = TwoPlayerPlayerOnePayoffMatrix()
    }
}

class PlayerTwoView:PlayerView {
    
    override init() {
        super.init()
        buttonVector = HorizontalButtonVector()
        payOffMatrix = TwoPlayerPlayerTwoPayoffMatrix()
    }
}

class PlayerView    {
    
    var payOffMatrix:PayoffMatrix?
    var buttonVector:ButtonVector?
    
    init() {}
    
}
