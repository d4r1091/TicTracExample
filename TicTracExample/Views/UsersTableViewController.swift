//
//  UsersTableViewController.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 07/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import UIKit
import MBProgressHUD

class UsersTableViewController: UITableViewController, UISearchResultsUpdating, UserListTableViewCellDelegate {
    
    // MARK: - Outlet's Actions
    
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        refreshUsersList()
    }
    
    
    // MARK: - Properties
    
    private var users = [UserModel]()
    private var searchResults = [UserModel]()
    private var lastIndexPath: NSIndexPath?
    private var currentIndexPath: NSIndexPath?
    private var resultSearchController = UISearchController()
    
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
    
    func getUsersRemote(fetchFromServer: Bool) {
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.label.text = "fetching users list...";
        UserController.getUsersList(fetchFromServer) { (users: [UserModel]?) in
            self.fillArray(users)
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
                progressHUD.hideAnimated(true)
            })
        }
    }
    
    func fillArray(list: [UserModel]?) {
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
        self.refreshControl?.addTarget(self, action: #selector(UsersTableViewController.refreshUsersList), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func reloadLastTableViewCell(indexPath: NSIndexPath) {
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func expandTableViewRow(cell: UITableViewCell) {
        let myCell = cell as! UserListTableViewCell
        tableView.beginUpdates()
        myCell.heightConstraint.constant = 90.0
        tableView.endUpdates()
    }
    
    func refreshUsersList() {
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.label.text = "refreshing users list...";
        UserController.refreshUsersList { (users: [UserModel]?) in
            self.fillArray(users)
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
                progressHUD.hideAnimated(true)
                self.refreshControl?.endRefreshing()
            })
        }
    }
}

// MARK: - Table View Data Source & Delegate

extension UsersTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.active) {
            guard searchResults.count > 0 else {
                return 0
            }
            return searchResults.count
        }
        else {
            return users.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("usersCellReuseIdentifier", forIndexPath: indexPath) as! UserListTableViewCell
        var arrayOfUsers:Array<UserModel>?
        if (resultSearchController.active) {
            arrayOfUsers = searchResults
        } else {
            arrayOfUsers = users
        }
        let anUser = arrayOfUsers![indexPath.row]
        cell.configureCellViews(anUser.name,
                                email: anUser.email,
                                infos: anUser.infos)
        cell.delegate = self
        return cell
    }
}

// MARK: - Cell Delegate

extension UsersTableViewController {
    func didClickedUpdateNavigationBar(newTitle: String?, cell: UITableViewCell) {
        expandTableViewRow(cell)
        if lastIndexPath != nil {
            reloadLastTableViewCell(lastIndexPath!)
        }
        lastIndexPath = tableView.indexPathForCell(cell)
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
    
    func filterContentForSearchText(searchText: String) {
        guard users.count > 0 else {
            return
        }
        searchResults = users.filter({( anUser: UserModel) -> Bool in
            return anUser.name?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || anUser.email?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchResults.removeAll(keepCapacity: false)
        filterContentForSearchText(searchController.searchBar.text!)
        self.tableView.reloadData()
    }
}
