//
//  AboutViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 3/17/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import ActiveLabel

class AboutViewController : UIViewController {

    @IBOutlet weak var inMemoryOfLabel: ActiveLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inMemoryOfLabel.textColor = UIColor.white
        self.inMemoryOfLabel.textAlignment = .center
        self.inMemoryOfLabel.text = "Built in loving memory of @pishi and @giovanni"
        self.inMemoryOfLabel.handleMentionTap(self.openUsername)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpModalBar(title: "About")
    }
}
