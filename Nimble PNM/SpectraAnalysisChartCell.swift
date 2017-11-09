//
//  SpectraAnalysisChartCell.swift
//  Nimble PNM
//
//  Created by KSolves on 24/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import Charts

class SpectraAnalysisChartCell : UITableViewCell{
    
    @IBOutlet weak var buttonShowHideImpairments: UIButton!
    @IBOutlet weak var buttonShowHideChannels: UIButton!

    @IBOutlet weak var combinedChartView: CombinedChartView!
}
