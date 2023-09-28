//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Nehemiah James on 9/25/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    
    enum AnimationStyle {
      case slide
      case fade
    }
    
    var dismissStyle = AnimationStyle.fade
    var searchResult: SearchResult! {
      didSet {
        if isViewLoaded {
           updateUI()
        }
      }
    }
    var downloadTask: URLSessionDownloadTask?
    var isPopUp = false

    override func viewDidLoad() {
      super.viewDidLoad()
      if isPopUp {
        popupView.layer.cornerRadius = 10
        let gestureRecognizer = UITapGestureRecognizer(
          target: self,
          action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        // Gradient view
        view.backgroundColor = UIColor.clear
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)
      } else {
        view.backgroundColor = UIColor(patternImage: UIImage(
          named: "LandscapeBackground")!)
        popupView.isHidden = true
      }
      if searchResult != nil {
    updateUI() }
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      transitioningDelegate = self
    }
    
    deinit {
      print("deinit \(self)")
      downloadTask?.cancel()
    }
    
    // MARK: - Actions
    @IBAction func close() {
      dismissStyle = .slide  
      dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    func updateUI() {
      nameLabel.text = searchResult.name
      if searchResult.artist.isEmpty {
        artistNameLabel.text = NSLocalizedString("Unknown", comment: "Error alert: text")
    } else {
        artistNameLabel.text = searchResult.artist
      }
      kindLabel.text = searchResult.type
      genreLabel.text = searchResult.genre
        
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Error alert: prixeText")
        }
        else if let text = formatter.string(from: searchResult.price as NSNumber) {
          priceText = text
        }
        else {
          priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        if let largeURL = URL(string: searchResult.imageLarge) {
          downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
        popupView.isHidden = false
        
    }

    @IBAction func openInStore() {
      if let url = URL(string: searchResult.storeURL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
    
}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    return (touch.view === self.view)
  }
}

extension DetailViewController:
UIViewControllerTransitioningDelegate {
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }
    
    func animationController(
      forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
      switch dismissStyle {
      case .slide:
        return SlideOutAnimationController()
      case .fade:
        return FadeOutAnimationController()
      }
    }
    
}
