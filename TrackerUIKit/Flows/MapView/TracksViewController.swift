//
//  TracksViewController.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 23.03.2022.
//

import UIKit
import RealmSwift

class TracksViewController: UIViewController {
    let tableView = UITableView()
    
    var tracks: Results<Track>?
    var completion: (([String?], String?) -> Void)?
    
    override func loadView() {
        super.loadView()
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension TracksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "\(tracks?[indexPath.row].startDate ?? Date()) - \(tracks?[indexPath.row].endDate ?? Date())"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Saved tracks"
    }
}

extension TracksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tracks = tracks?[indexPath.row] else { return }
        let encodedPaths = Array(tracks.encodedPaths)
        let fullPath = tracks.fullPath
        completion?(encodedPaths, fullPath)
        dismiss(animated: true)
    }
}
