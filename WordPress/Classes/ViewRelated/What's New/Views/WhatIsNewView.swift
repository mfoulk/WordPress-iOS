
/// Labels and button titles
struct WhatIsNewViewTitles {
    let header: String
    let version: String
    let continueButtonTitle: String
}


/// Main view of the What's New page
class WhatIsNewView: UIView {

    // MARK: - View elements
    private lazy var titleLabel: UILabel = {
        let label = makeLabel(viewTitles.header)
        label.font = Appearance.headlineFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var versionLabel: UILabel = {
        let label = makeLabel(viewTitles.version)

        // if there's no version, just hide the label and save that space
        guard !viewTitles.version.isEmpty else {
            label.isHidden = true
            return label
        }

        label.font = Appearance.subHeadlineFont
        label.textColor = .textSubtle
        return label
    }()

    private lazy var continueButton: UIButton = {
        let button = FancyButton()
        button.isPrimary = true
        button.titleFont = Appearance.continueButtonFont
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewTitles.continueButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var continueButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        view.pinSubviewToSafeArea(continueButton, insets: Appearance.continueButtonInsets)
        return view
    }()

    private lazy var announcementsTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView() // To hide the separators for empty cells
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Appearance.estimatedRowHeight
        return tableView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = makeVerticalStackView(arrangedSubviews: [titleLabel, versionLabel, announcementsTableView])
        stackView.setCustomSpacing(Appearance.titleVersionSpacing, after: titleLabel)
        stackView.setCustomSpacing(Appearance.versionTableviewSpacing, after: versionLabel)
        return stackView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStackView)
        view.pinSubviewToSafeArea(contentStackView, insets: Appearance.mainContentInsets)
        return view
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = makeVerticalStackView(arrangedSubviews: [contentView, continueButtonView])
        return stackView
    }()

    // MARK: - Properties
    private let viewTitles: WhatIsNewViewTitles
    private let dataSource: AnnouncementsDataSource

    var continueAction: (() -> Void)?

    init(viewTitles: WhatIsNewViewTitles, dataSource: AnnouncementsDataSource) {
        self.viewTitles = viewTitles
        self.dataSource = dataSource

        super.init(frame: .zero)

        backgroundColor = .basicBackground
        addSubview(mainStackView)
        pinSubviewToAllEdges(mainStackView)

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: Appearance.continueButtonHeight)
        ])
        setupTableViewDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Helpers
private extension WhatIsNewView {

    func makeVerticalStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }

    func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }

    func setupTableViewDataSource() {
        announcementsTableView.dataSource = dataSource
        dataSource.registerCells(for: announcementsTableView)
    }

    @objc func continueButtonTapped() {
        continueAction?()
    }
}


// MARK: - Appearance
private extension WhatIsNewView {

    enum Appearance {
        // main view
        static let mainContentInsets = UIEdgeInsets(top: 80, left: 48, bottom: 0, right: 48)

        // title
        static var headlineFont: UIFont {
            if #available(iOS 13.0, *),
                let serifHeadlineDescriptor = UIFontDescriptor
                    .preferredFontDescriptor(withTextStyle: .headline)
                    .withDesign(.serif) {

                return UIFont(descriptor: serifHeadlineDescriptor, size: 34)
            }
            return UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 34)
        }
        static let titleVersionSpacing: CGFloat = 16

        // version label
        static let subHeadlineFont = UIFont(descriptor: UIFontDescriptor
                .preferredFontDescriptor(withTextStyle: .subheadline), size: 15)
        static let versionTableviewSpacing: CGFloat = 32

        // table view
        static let estimatedRowHeight: CGFloat = 72 // image height + vertical spacing

        // continue button
        static let continueButtonHeight: CGFloat = 48
        static let continueButtonInset: CGFloat = 16
        static let continueButtonFont = UIFont.systemFont(ofSize: 22, weight: .medium)
        static let continueButtonInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    }
}
