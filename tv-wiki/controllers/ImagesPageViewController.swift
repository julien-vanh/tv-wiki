//
//  ImagesPageViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 29/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation

import UIKit

class ImagesPageViewController : UIPageViewController, UIPageViewControllerDelegate {
    var currentIndex = 0
    var images = [ImageMetadata]()
    
    private var currentViewController: UIViewController?
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers = [PageImageViewController]()
        for image in images {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PageImageViewController") as! PageImageViewController
            vc.image = image
            viewControllers.append(vc)
        }
        return viewControllers
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        let firstViewController = orderedViewControllers[currentIndex]
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
    }
}

extension ImagesPageViewController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    @IBAction func tap() {
        let vc = self.viewControllers!.first! as! PageImageViewController
        vc.toogleImageDescriptionView()
        
    }
}
