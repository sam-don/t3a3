import SpriteKit

/// Lightweight placeholder-art battle stage: emoji "sprites" for hero/enemy
/// so the combat loop has real visual feedback (lunges, hit flashes,
/// floating damage numbers) without needing custom art yet. Swapping these
/// SKLabelNodes for SKSpriteNode textures later is a localized change.
final class BattleScene: SKScene {
    private let heroLabel = SKLabelNode(text: "🥷")
    private let enemyLabel = SKLabelNode(text: "👹")
    private let backdrop = SKShapeNode()
    private let hpBarBackground = SKShapeNode(rectOf: CGSize(width: 140, height: 14), cornerRadius: 7)
    private let hpBarFill = SKShapeNode()
    private let hpBarWidth: CGFloat = 136

    private var heroDefaultPosition: CGPoint = .zero
    private var enemyDefaultPosition: CGPoint = .zero

    private static let enemyEmojiPool = ["🐍", "🕷️", "🦇", "🧟", "👻", "🐺", "🦂", "🐲", "🧌", "☠️"]

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        scaleMode = .aspectFit
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .clear
        buildScene()
    }

    private func buildScene() {
        backdrop.path = CGPath(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), transform: nil)
        backdrop.fillColor = SKColor(hue: 0.6, saturation: 0.35, brightness: 0.16, alpha: 1)
        backdrop.strokeColor = .clear
        backdrop.zPosition = -10
        addChild(backdrop)

        heroDefaultPosition = CGPoint(x: -size.width * 0.24, y: -10)
        enemyDefaultPosition = CGPoint(x: size.width * 0.24, y: -10)

        heroLabel.fontSize = 56
        heroLabel.verticalAlignmentMode = .center
        heroLabel.position = heroDefaultPosition
        heroLabel.zPosition = 5
        addChild(heroLabel)

        enemyLabel.fontSize = 56
        enemyLabel.verticalAlignmentMode = .center
        enemyLabel.position = enemyDefaultPosition
        enemyLabel.zPosition = 5
        addChild(enemyLabel)

        hpBarBackground.fillColor = SKColor(white: 0, alpha: 0.4)
        hpBarBackground.strokeColor = SKColor(white: 1, alpha: 0.25)
        hpBarBackground.position = CGPoint(x: enemyDefaultPosition.x, y: enemyDefaultPosition.y + 46)
        hpBarBackground.zPosition = 6
        addChild(hpBarBackground)

        hpBarFill.fillColor = .systemRed
        hpBarFill.strokeColor = .clear
        hpBarFill.zPosition = 7
        hpBarBackground.addChild(hpBarFill)
        setEnemyHPFraction(1)
    }

    // MARK: - Public API

    func configureEnemy(_ enemy: Enemy, hp: Double, zoneHue: Double) {
        setBackdropHue(zoneHue)
        updateEnemyHP(hp, maxHP: enemy.maxHP)

        let targetScale: CGFloat = enemy.isBoss ? 1.35 : 1.0
        enemyLabel.text = enemy.isBoss ? "👑" : Self.enemyEmojiPool[enemy.floor % Self.enemyEmojiPool.count]
        enemyLabel.removeAllActions()
        enemyLabel.alpha = 0
        enemyLabel.setScale(targetScale * 0.4)
        enemyLabel.run(.group([
            .fadeIn(withDuration: 0.25),
            .scale(to: targetScale, duration: 0.25)
        ]))
    }

    func updateEnemyHP(_ hp: Double, maxHP: Double) {
        let fraction = maxHP > 0 ? CGFloat(hp / maxHP) : 0
        setEnemyHPFraction(fraction)
    }

    func heroAttacked(damage: Double, isCrit: Bool) {
        let lunge = SKAction.sequence([
            .move(to: CGPoint(x: heroDefaultPosition.x + 30, y: heroDefaultPosition.y), duration: 0.08),
            .move(to: heroDefaultPosition, duration: 0.12)
        ])
        heroLabel.run(lunge)
        punch(enemyLabel)
        showFloatingText(
            isCrit ? "CRIT \(Int(damage))" : "\(Int(damage))",
            color: isCrit ? .systemYellow : .white,
            near: enemyLabel.position
        )
    }

    func enemyAttacked(damage: Double) {
        let lunge = SKAction.sequence([
            .move(to: CGPoint(x: enemyDefaultPosition.x - 30, y: enemyDefaultPosition.y), duration: 0.08),
            .move(to: enemyDefaultPosition, duration: 0.12)
        ])
        enemyLabel.run(lunge)
        punch(heroLabel)
        showFloatingText("\(Int(damage))", color: .systemRed, near: heroLabel.position)
    }

    func enemyDefeated() {
        enemyLabel.removeAllActions()
        enemyLabel.run(.group([
            .fadeOut(withDuration: 0.25),
            .scale(by: 0.5, duration: 0.25)
        ]))
    }

    // MARK: - Private helpers

    private func setEnemyHPFraction(_ fraction: CGFloat) {
        let clamped = max(0, min(1, fraction))
        let width = max(0.001, hpBarWidth * clamped)
        let rect = CGRect(x: -hpBarWidth / 2, y: -6, width: width, height: 12)
        hpBarFill.path = CGPath(roundedRect: rect, cornerWidth: 5, cornerHeight: 5, transform: nil)
    }

    private func setBackdropHue(_ hue: Double) {
        backdrop.fillColor = SKColor(hue: CGFloat(hue), saturation: 0.45, brightness: 0.16, alpha: 1)
    }

    private func punch(_ node: SKLabelNode) {
        let baseScale = node.xScale
        node.run(.sequence([
            .scale(to: baseScale * 1.25, duration: 0.05),
            .scale(to: baseScale, duration: 0.1)
        ]))
    }

    private func showFloatingText(_ text: String, color: SKColor, near position: CGPoint) {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = color
        label.position = CGPoint(x: position.x + CGFloat.random(in: -10...10), y: position.y + 40)
        label.zPosition = 20
        addChild(label)
        label.run(.sequence([
            .group([
                .moveBy(x: 0, y: 36, duration: 0.6),
                .fadeOut(withDuration: 0.6)
            ]),
            .removeFromParent()
        ]))
    }
}
