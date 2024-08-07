//
//  ShoppingTableViewController.swift
//  ShoppingListApp
//
//  Created by 심소영 on 5/24/24.
//

import UIKit
import RxSwift
import RxCocoa

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
    let disposeBag = DisposeBag()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .systemGray6
        configuration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
    lazy var list = BehaviorSubject(value: checkList)
    
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
        textField.font = .boldSystemFont(ofSize: 14)
        textField.layer.cornerRadius = 10
        textField.textColor = .black
        textField.backgroundColor = .systemGray6
        
        addbutton.titleLabel?.text = "추가"
        addbutton.backgroundColor = .systemGray4
        addbutton.tintColor = .black
        addbutton.layer.cornerRadius = 10
        buttonView.backgroundColor = .systemGray6
        tableView.rowHeight = 50
        addbutton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        configurationCell()
        bind()
    }
    
    func bind(){
        list
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                let check = element.check ? "checkmark.square.fill" : "checkmark.square"
                cell.checkImageView.rx.image = UIImage(systemName: check)
                
                let star = element.star ? "star.fill" : "star"
                let starImage = UIImage(systemName: star)
                cell.starButton.setImage(starImage, for: .normal)
                
                cell.checkButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.checkList[row].check.toggle()
                        self?.list.onNext(self?.checkList ?? [])
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.starButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.checkList[row].star.toggle()
                        self?.list.onNext(self?.checkList ?? [])
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.checkList.remove(at: indexPath.row)
                self?.list.onNext(self?.checkList ?? [])
            })
            .disposed(by: disposeBag)
        
        addbutton.rx.tap
            .subscribe(onNext: { value in
                guard let text = self.textField.text, text.count > 1 else {
                    self.textField.placeholder = "2글자 이상 입력해주세요"
                    return
                }
                let newItem = ShoppingList(star: false, check: false, textLabel: text)
                self.checkList.append(newItem)
                
                self.textField.text = ""
                self.list.onNext(self.checkList)
            })
            .disposed(by: disposeBag)
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
            background.backgroundColor = .systemGray6
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
        cell.backgroundColor = .systemGray6
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
