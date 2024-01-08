//  TimeSettingViewController.swift
//  Pomodoro
//
//  Created by 진세진 on 2023/12/21.
//  Copyright © 2023 io.hgu. All rights reserved.

import UIKit
import Then
import SnapKit


protocol PomodoroTimePickerDelegate {
    func didSelectTimer(time : Int)
}

final class TimeSettingViewController: UIViewController {
    
    
    private var isSelectedTime : Bool = false
    private let colletionViewIdentifier = "Cell"
    private var heightProportionForMajorCell : CGFloat?
    private var centerIndexPath : IndexPath?
    public var selectedTime : Int = 0
    
    var delegate : PomodoroTimePickerDelegate
    
    init(isSelectedTime: Bool, heightProportionForMajorCell: CGFloat? = nil, centerIndexPath: IndexPath? = nil, delegate: PomodoroTimePickerDelegate) {
        self.isSelectedTime = isSelectedTime
        self.heightProportionForMajorCell = heightProportionForMajorCell
        self.centerIndexPath = centerIndexPath
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var timeSettingbutton = UIButton().then {
        $0.setTitle("설정 완료", for: .normal)
        $0.setTitleColor( .black , for: .normal)
        $0.addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    
    private var titleTime = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        $0.textAlignment = .center
    }
    
    private lazy var collectionFlowlayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionFlowlayout).then {
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = true
        $0.register(TimerCollectionViewCell.self, forCellWithReuseIdentifier: colletionViewIdentifier)
        $0.showsHorizontalScrollIndicator = false
        let padding = view.bounds.width / 2 - collectionFlowlayout.itemSize.width / 2
        $0.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        setUplayout()
    }
    
    private func setUplayout() {
        view.addSubview(collectionView)
        view.addSubview(titleTime)
        view.addSubview(timeSettingbutton)
        
        heightProportionForMajorCell = 0.2
        let maximumCellHeight = view.bounds.width * (heightProportionForMajorCell ?? 0.2)
        collectionView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-(view.bounds.height * 0.3))
            make.leading.equalTo(view.bounds.width * 0.15)
            make.trailing.equalToSuperview()
            make.height.equalTo(maximumCellHeight)
        }
    
        titleTime.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.bounds.height * 0.2)
            make.centerX.equalToSuperview()
        }
        
        timeSettingbutton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo( -(view.bounds.height * 0.2))
        }
        
        
    }
    
    @objc private func onClick() {
        self.delegate.didSelectTimer(time: Int(centerIndexPath?.item ?? 0))
        navigationController?.popViewController(animated: true)
    }
}

extension TimeSettingViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colletionViewIdentifier, for: indexPath) as? TimerCollectionViewCell else {
            return  UICollectionViewCell()
        }
        
        if indexPath.item % 5 == 0 {
            cell.timeLabel.textColor = .black
        } else {
            cell.timeLabel.textColor = .white
        }
        
        cell.timeLabel.text = "\(Int(indexPath.item))"
        
        isSelectedTime = indexPath == centerIndexPath
        cell.isSelectedTime = isSelectedTime
        cell.backgroundColor = .white
    
        return cell
    }
}

extension TimeSettingViewController : UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.bounds.width / 2), y:  (scrollView.bounds.height / 2))
        
        guard let centerIndexPathCalculation = collectionView.indexPathForItem(at: center) else {
            return
        }
        
        let hours = Int(centerIndexPathCalculation.item) / 60
        let minutes = Int(centerIndexPathCalculation.item) % 60
        titleTime.text = String(format: "%02d:%02d", hours, minutes)
        
        if centerIndexPath != centerIndexPathCalculation {
            centerIndexPath = centerIndexPathCalculation
            collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let widthProportionForMajorCell: CGFloat = 0.23
        let widthProportionForMinorCell: CGFloat = 0.12
        let heightProportionForMajorCell: CGFloat = 0.2
        let heightProportionForMinorCell: CGFloat = 0.12

        let width = collectionView.bounds.width
        let cellWidthForMajor = width * widthProportionForMajorCell
        let cellWidthForMinor = width * widthProportionForMinorCell
        let cellHeightForMajor = width * heightProportionForMajorCell
        let cellHeightForMinor = width * heightProportionForMinorCell

        // Return size based on the indexPath item.
        if indexPath.item % 5 == 0 {
           return CGSize(width: cellWidthForMajor, height: cellHeightForMajor)
        } else {
           return CGSize(width: cellWidthForMinor, height: cellHeightForMinor)
        }
    }
}
