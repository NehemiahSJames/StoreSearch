//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Nehemiah James on 9/28/23.
//

import UIKit

protocol MenuViewControllerDelegate: AnyObject {
  func menuViewControllerSendEmail(_ controller: MenuViewController)
}

class MenuViewController: UITableViewController {

    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table View Delegates
    override func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ){
    tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
        delegate?.menuViewControllerSendEmail(self)
      }
    }
    
}
