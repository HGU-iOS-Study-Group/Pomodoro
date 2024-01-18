//
//  TagModalViewController.swift
//  Pomodoro
//
//  Created by SonSinghae on 2023/11/17.
//  Copyright © 2023 io.hgu. All rights reserved.
//
import SnapKit
import Then
import UIKit

final class TagModalViewController: UIViewController {
    
    private var tagCollectionView: TagCollectionView!
    private let dataSource = TagCollectionViewData.data
    
    private let horizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    
    private let label = UILabel().then {
        $0.text = "태그선택"
        $0.textColor = .white
        //$0.font = UIFont.systemFont(ofSize: 28)
        $0.font = UIFont.boldSystemFont(ofSize: 26)
    }
    
    private let circleButton = UIButton().then {
        $0.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .black
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
     }

    
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .fill
    }
    // MARK: - TODO
    @objc private func circleButtonTapped() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        
        registerCollectionView()
        
        configureCollectionViewDelegate()
        
        configureLayout()
        
    }
    
    
    private func configureLayout() {
        
        horizontalStackView.addArrangedSubview(label)
        horizontalStackView.addArrangedSubview(circleButton)
        
        mainStackView.addArrangedSubview(horizontalStackView)
        mainStackView.addArrangedSubview(tagCollectionView)
        
        view.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    
    private func configureCollectionView() {
        
        let collectionViewLayer = UICollectionViewFlowLayout()
        collectionViewLayer.sectionInset = UIEdgeInsets(top: 5.0, left: 7.0, bottom: 5.0, right: 7.0)
        collectionViewLayer.minimumLineSpacing = 5
        collectionViewLayer.minimumInteritemSpacing = 1
        
        tagCollectionView = TagCollectionView(frame: .zero, collectionViewLayout: collectionViewLayer)
        tagCollectionView.backgroundColor = .secondarySystemBackground
        view.addSubview(tagCollectionView)
        
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(120)
            make.left.right.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func registerCollectionView() {
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.id)
    }
    
    private func configureCollectionViewDelegate() {
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
    }
    
}

extension TagModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let totalPadding = padding * (2 - 1)
        let individualPadding = totalPadding / 2
        let width = (collectionView.bounds.width - totalPadding) / 2
        let height: CGFloat = 70 

        return CGSize(width: width - individualPadding, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                TagCollectionViewCell.id, for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = dataSource[indexPath.item]
        return cell
    }
}