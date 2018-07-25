import XCTest
@testable import WordPress

final class FormattableContentGroupTests: XCTestCase {
    private let contextManager = TestContextManager()
    private var subject: FormattableContentGroup?

    private struct Constants {
        static let kind: FormattableContentGroup.Kind = .activity
    }

    override func setUp() {
        super.setUp()
        ContextManager.overrideSharedInstance(nil)
        subject = FormattableContentGroup(blocks: [mockContent()], kind: Constants.kind)
    }

    override func tearDown() {
        subject = nil
        ContextManager.overrideSharedInstance(nil)
        super.tearDown()
    }

    func testKindRemainsAsInitialised() {
        XCTAssertEqual(subject?.kind, Constants.kind)
    }

    func testBlocksRemainAsInitialised() {
        let groupBlocks = subject?.blocks as? [FormattableTextContent]
        let mockBlocks = [mockContent()]

        /// Compare by the blocks' text
        let groupBlocksText = groupBlocks!.map { $0.text }
        let mockBlocksText = mockBlocks.map { $0.text }

        XCTAssertEqual(groupBlocksText, mockBlocksText)
    }

    func testBlockOfKindReturnsExpectation() {
        let obtainedBlock: FormattableTextContent? = subject?.blockOfKind(.text)
        let obtainedBlockText = obtainedBlock?.text

        let mockText = mockContent().text

        XCTAssertEqual(obtainedBlockText, mockText)
    }

    func testBlockOfKindReturnsNilWhenNotFound() {
        let obtainedBlock: FormattableTextContent? = subject?.blockOfKind(.image)

        XCTAssertNil(obtainedBlock)
    }

    func testLikeNotificationContainsUserContentGroupsInTheBody() {
        let note = loadLikeNotification()
        for group in note.bodyContentGroups {
            XCTAssertTrue(group.kind == .user)
        }
    }

    func testFollowerNotificationContainsUserAndFooterGroupsInTheBody() {
        let note = loadFollowerNotification()

        // Note: Account for 'View All Followers'
        for group in note.bodyContentGroups {
            XCTAssertTrue(group.kind == .user || group.kind == .footer)
        }
    }

    var entityName: String {
        return Notification.classNameWithoutNamespaces()
    }

    func loadLikeNotification() -> WordPress.Notification {
        return contextManager.loadEntityNamed(entityName, withContentsOfFile: "notifications-like.json") as! WordPress.Notification
    }

    func loadFollowerNotification() -> WordPress.Notification {
        return contextManager.loadEntityNamed(entityName, withContentsOfFile: "notifications-new-follower.json") as! WordPress.Notification
    }

    private func mockContent() -> FormattableTextContent {
        return FormattableTextContent(dictionary: mockActivity(), actions: [], ranges: [], parent: mockParent())
    }

    private func mockActivity() -> [String: AnyObject] {
        return getDictionaryFromFile(named: "activity-log-activity-content.json")
    }

    private func getDictionaryFromFile(named fileName: String) -> [String: AnyObject] {
        return contextManager.object(withContentOfFile: fileName) as! [String: AnyObject]
    }

    func mockParent() -> FormattableContentParent {
        return MockActivityParent()
    }
}
