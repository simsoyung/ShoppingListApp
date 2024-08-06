//
//  ShoppingTableViewCell.swift
//  ShoppingListApp
//
//  Created by 심소영 on 5/24/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ShoppingTableViewCell: UITableViewCell {
    
    
    static let identifier = "ShoppingTableViewCell"
    var disposeBag = DisposeBag()
    let todoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    let likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemGray6
        self.backgroundColor = .clear
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(todoLabel)
        contentView.addSubview(checkImageView)
        contentView.addSubview(likeImageView)
        
        checkImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(12)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.size.equalTo(25)
        }
        todoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkImageView)
            make.leading.equalTo(checkImageView.snp.trailing).offset(20)
            make.height.equalTo(30)
        }
        likeImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            make.size.equalTo(25)
        }
    }
    
}
