//
//  ShoppingTableViewController.swift
//  ShoppingListApp
//
//  Created by 심소영 on 5/24/24.
//

import UIKit

struct ShoppingList: Hashable, Identifiable {
    let id = UUID()
    var star: Bool
    var check: Bool
    let textLabel: String
}

enum Section: CaseIterable {
    case main
    case snb
    case last
}

class ShoppingTableViewController: UITableViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var addbutton: UIButton!
    @IBOutlet var buttonView: UIView!
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .gray
        configuration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ShoppingList>!
    
    var checkList = [
    ShoppingList(star: true, check: false, textLabel: "그립톡 구매하기"),
    ShoppingList(star: true, check: false, textLabel: "사이다 구매"),
    ShoppingList(star: false, check: true, textLabel: "양말"),
    ShoppingList(star: true, check: true, textLabel: "양배추"),
    ShoppingList(star: false, check: false, textLabel: "아이패드 케이스"),
    ShoppingList(star: true, check: true, textLabel: "자전거"),
    ShoppingList(star: false, check: false, textLabel: "노트"),
    ShoppingList(star: false, check: true, textLabel: "세탁세제"),
    ShoppingList(star: true, check: true, textLabel: "면봉"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        textField.placeholder = "무엇을 구매하실 건가요?"
        textField.font = .boldSystemFont(ofSize: 13)
        textField.layer.cornerRadius = 10
        textField.textColor = .black
        textField.backgroundColor = .systemGray5
        
        addbutton.titleLabel?.text = "추가"
        addbutton.backgroundColor = .systemGray4
        addbutton.tintColor = .black
        addbutton.layer.cornerRadius = 10
        buttonView.backgroundColor = .systemGray5
        tableView.rowHeight = 50
        addbutton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        configurationCell()
        
    }
    
    func updateData(){
        var snapshot = NSDiffableDataSourceSnapshot<Section, ShoppingList>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(checkList, toSection: .main)
        snapshot.appendItems([ShoppingList(star: false, check: false, textLabel: "집가기")], toSection: .snb)
        dataSource.apply(snapshot)
    }
    
    private func configurationCell(){
        var registeration: UICollectionView.CellRegistration<UICollectionViewListCell, ShoppingList>!
        registeration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.textLabel
            if itemIdentifier.check {
                content.image = UIImage(systemName: "star.fill")
            } else {
                content.image = UIImage(systemName: "star")
            }
            cell.contentConfiguration = content
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .gray
            background.cornerRadius = 10
            background.strokeWidth = 1
            background.strokeColor = .systemBlue
            cell.backgroundConfiguration = background
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: registeration, for: indexPath, item: itemIdentifier)
            return cell
        })
    
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @objc
    func checkButtonTapped(sender: UIButton){
        checkList[sender.tag].check.toggle()
        tableView.reloadData()
    }
    
    @objc
    func starButtonTapped(sender:UIButton){
        checkList[sender.tag].star.toggle()
        tableView.reloadData()
    }
    
    @objc
    func addButtonClicked(){
        guard let text = textField.text, text.count > 1 else {
            return textField.placeholder = "2글자 이상 입력해주세요"
        }
        let add = ShoppingList(star: true, check: true, textLabel: text)
        checkList.append(add)
        
        textField.text = ""
        tableView.reloadData()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingTableViewCell") as! ShoppingTableViewCell
        
        let date = checkList[indexPath.row]
        cell.mainLabel.text = date.textLabel
        cell.mainLabel.font = UIFont.systemFont(ofSize: 12)
        cell.mainLabel.textColor = .black
        cell.mainLabel.textAlignment = .left
        cell.backgroundColor = .systemGray5
        cell.contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.tintColor = .black
        
        let check = date.check ? "checkmark.square.fill" : "checkmark.square"
        let image = UIImage(systemName: check)
        cell.checkButton.setImage(image, for: .normal)
        
        let star = date.star ? "star.fill" : "star"
        let starImage = UIImage(systemName: star)
        cell.starButton.setImage(starImage, for: .normal)
     

        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action:#selector(checkButtonTapped), for: .touchUpInside)
        
        cell.starButton.tag = indexPath.row
        cell.starButton.addTarget(self, action:#selector(starButtonTapped), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkList.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            checkList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
}
