//
//  HomeCustomSegue.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 27/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class HomeCustomSegue: UIStoryboardSegue {
    
    override func perform() {
        
        let sourceVC = self.source
        let destinationVC = self.destination
        
        sourceVC.view.addSubview(destinationVC.view)
        
        destinationVC.view.transform = __CGAffineTransformMake(<#T##a: CGFloat##CGFloat#>, <#T##b: CGFloat##CGFloat#>, <#T##c: CGFloat##CGFloat#>, <#T##d: CGFloat##CGFloat#>, 0.05, 0.05)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { () -> void in
            
             destinationVC.view.transform = __CGAffineTransformMake(<#T##a: CGFloat##CGFloat#>, <#T##b: CGFloat##CGFloat#>, <#T##c: CGFloat##CGFloat#>, <#T##d: CGFloat##CGFloat#>, 0.05, 0.05)
        }) {(finished) -> void in
         
            
            
        }
    }

}
