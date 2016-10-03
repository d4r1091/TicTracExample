//
//  UsersTableViewController.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 07/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import UIKit
import MBProgressHUD
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class UsersTableViewController: UITableViewController, UISearchResultsUpdating, UserListTableViewCellDelegate {
    
    // MARK: - Outlet's Actions
    
    @IBAction func refreshButtonClicked(_ sender: AnyObject) {
        refreshUsersList()
    }
    
    
    // MARK: - Properties
    
    fileprivate var users = [UserModel]()
    fileprivate var searchResults = [UserModel]()
    fileprivate var lastIndexPath: IndexPath?
    fileprivate var currentIndexPath: IndexPath?
    fileprivate var resultSearchController = UISearchController()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users List"
        setTableViewStuffs()
        initializeSearchController()
        fetchUsersIfNeeded()
    }
    
    // MARK: - Helper functions
    
    func fetchUsersIfNeeded() {
        getUsersRemote(!UserController.usersStored())
    }
    
    func getUsersRemote(_ fetchFromServer: Bool) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = "fetching users list...";
        UserController.getUsersList(fetchFromServer) { (users: [UserModel]?) in
            self.fillArray(users)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                progressHUD.hide(animated: true)
            })
        }
    }
    
    func fillArray(_ list: [UserModel]?) {
        guard list?.count > 0 else {
            return
        }
        users = list!
    }
    
}

// MARK: - Table View Hacking

extension UsersTableViewController {
    
    func setTableViewStuffs() {
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableViewAutomaticDimension
        self.refreshControl?.addTarget(self, action: #selector(UsersTableViewController.refreshUsersList), for: UIControlEvents.valueChanged)
    }
    
    func reloadLastTableViewCell(_ indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func expandTableViewRow(_ cell: UITableViewCell) {
        let myCell = cell as! UserListTableViewCell
        tableView.beginUpdates()
        myCell.heightConstraint.constant = 90.0
        tableView.endUpdates()
    }
    
    func refreshUsersList() {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = "refreshing users list...";
        UserController.refreshUsersList { (users: [UserModel]?) in
            self.fillArray(users)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                progressHUD.hide(animated: true)
                self.refreshControl?.endRefreshing()
            })
        }
    }
}

// MARK: - Table View Data Source & Delegate

extension UsersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.isActive) {
            guard searchResults.count > 0 else {
                return 0
            }
            return searchResults.count
        }
        else {
            return users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCellReuseIdentifier", for: indexPath) as! UserListTableViewCell
        var arrayOfUsers:Array<UserModel>?
        if (resultSearchController.isActive) {
            arrayOfUsers = searchResults
        } else {
            arrayOfUsers = users
        }
        let anUser = arrayOfUsers![(indexPath as NSIndexPath).row]
        cell.configureCellViews(anUser.name,
                                email: anUser.email,
                                infos: anUser.infos)
        cell.delegate = self
        return cell
    }
}

// MARK: - Cell Delegate

extension UsersTableViewController {
    func didClickedUpdateNavigationBar(_ newTitle: String?, cell: UITableViewCell) {
        expandTableViewRow(cell)
        if lastIndexPath != nil {
            reloadLastTableViewCell(lastIndexPath!)
        }
        lastIndexPath = tableView.indexPath(for: cell)
        title = newTitle
    }
}

// MARK: - UISearchController Managing

extension UsersTableViewController {
    
    func initializeSearchController() {
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        guard users.count > 0 else {
            return
        }
        searchResults = users.filter({( anUser: UserModel) -> Bool in
            return anUser.name?.lowercased().range(of: searchText.lowercased()) != nil || anUser.email?.lowercased().range(of: searchText.lowercased()) != nil
        })
    }
    
    @objc(updateSearchResultsForSearchController:) func updateSearchResults(for searchController: UISearchController) {
        searchResults.removeAll(keepingCapacity: false)
        filterContentForSearchText(searchController.searchBar.text!)
        self.tableView.reloadData()
    }
}
