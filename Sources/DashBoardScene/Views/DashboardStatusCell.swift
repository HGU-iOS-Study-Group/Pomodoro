//
//  DashboardStatusCell.swift
//  Pomodoro
//
//  Created by 김하람 on 1/30/24.
//  Copyright © 2024 io.hgu. All rights reserved.
//

import DGCharts
import SnapKit
import Then
import UIKit

final class DashboardStatusCell: UICollectionViewCell {
    private let database = DatabaseManager.shared

    private let participateLabel = UILabel()
    private let countLabel = UILabel()
    private let achieveLabel = UILabel()
    private let failLabel = UILabel()
    private var selectedDate: Date = .init()

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("이 생성자를 사용하려면 스토리보드를 구현해주세요.")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupLabel(_ titleLabel: String, contentLabel: UILabel) -> UIView {
        let circleSize = 120
        let circleView = UIView().then {
            contentView.addSubview($0)
            $0.backgroundColor = .white
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(circleSize)
            }
            $0.layer.cornerRadius = CGFloat(circleSize / 2)
        }
        let titleLabel = UILabel().then {
            circleView.addSubview($0)
            $0.text = titleLabel
            $0.textColor = .darkGray
        }

        circleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
        }

        contentLabel.then {
            circleView.addSubview($0)
            $0.text = contentLabel.text
            $0.textColor = .black
            $0.font = UIFont.heading3()
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
        }
        return circleView
    }

    private func setupUI() {
        let circleStackView = UIStackView().then {
            contentView.addSubview($0)

            $0.addArrangedSubview(setupLabel("횟수", contentLabel: countLabel))
            $0.addArrangedSubview(setupLabel("실패", contentLabel: failLabel))
            $0.addArrangedSubview(setupLabel("달성", contentLabel: achieveLabel))
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 10
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }

        layer.cornerRadius = 20
        backgroundColor = .black
    }

    private func getStartAndEndDate(
        for date: Date,
        of component: Calendar.Component
    ) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        guard let dateInterval = calendar.dateInterval(of: component, for: date) else {
            return (date, date)
        }
        let startDate = dateInterval.start
        let endDate = dateInterval.end
        return (startDate, endDate)
    }

    func updateUI(for date: Date, dateType: DashboardDateType) {
        let component: Calendar.Component = {
            switch dateType {
            case .day:
                return .day
            case .week:
                return .weekOfYear
            case .month:
                return .month
            case .year:
                return .year
            }
        }()

        let (startDate, endDate) = getStartAndEndDate(for: date, of: component)

        let data = database.read(Pomodoro.self)
        print(data)

        let filteredData = data.filter { $0.participateDate >= startDate &&
            $0.participateDate < endDate
        }
        let participateDates = Set(filteredData.map { Calendar.current.startOfDay(for: $0.participateDate) })
        let totalParticipateCount = participateDates.count
        let filteredDataCount = filteredData.count
        let totalSuccessCount = filteredData.filter(\.isSuccess).count
        let totalFailureCount = filteredData.filter { !$0.isSuccess }.count

        participateLabel.text = "\(totalParticipateCount)번"
        countLabel.text = "\(filteredDataCount)번"
        achieveLabel.text = "\(totalSuccessCount)번"
        failLabel.text = "\(totalFailureCount)번"
        countLabel.font = UIFont.heading3()
        achieveLabel.font = UIFont.heading3()
        failLabel.font = UIFont.heading3()
    }

    func getDateRange(for date: Date, dateType: DashboardDateType) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch dateType {
        case .day:
            return (date, calendar.date(byAdding: .day, value: 1, to: date) ?? .now)
        case .week:
            let startOfWeek = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? .now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? .now
            return (startOfWeek, endOfWeek)
        case .month:
            let startOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: date)
            ) ?? .now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? .now
            return (startOfMonth, endOfMonth)
        case .year:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: date)) ?? .now
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? .now
            return (startOfYear, endOfYear)
        }
    }
}

// MARK: - DayViewControllerDelegate

extension DashboardStatusCell: DashboardTabDelegate {
    func dateArrowButtonDidTap(data date: Date) {
        selectedDate = date
    }
}
