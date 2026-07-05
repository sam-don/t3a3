import SpriteKit
import UIKit

/// Lightweight placeholder-art battle stage: emoji "sprites" for hero/enemy
/// so the combat loop has real visual feedback (lunges, hit flashes,
/// floating damage numbers) without needing custom art yet. Swapping these
/// SKLabelNodes for SKSpriteNode textures later is a localized change.
final class BattleScene: SKScene {
    private let heroLabel = SKLabelNode(text: "🥷")
    private let enemyLabel = SKLabelNode(text: "👹")
    private let backdrop = SKSpriteNode(color: .black, size: .zero)
    private let emberEmitter = SKEmitterNode()
    private let hpBarBackground = SKShapeNode(rectOf: CGSize(width: 140, height: 14), cornerRadius: 7)
    private let hpBarFill = SKShapeNode()
    private let hpBarHighlight = SKShapeNode()
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
        backdrop.size = size
        backdrop.position = .zero
        backdrop.zPosition = -10
        addChild(backdrop)
        setBackdropHue(0.6)

        configureEmberEmitter()

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

        hpBarBackground.fillColor = SKColor(white: 0, alpha: 0.45)
        hpBarBackground.strokeColor = SKColor(white: 1, alpha: 0.2)
        hpBarBackground.position = CGPoint(x: enemyDefaultPosition.x, y: enemyDefaultPosition.y + 46)
        hpBarBackground.zPosition = 6
        addChild(hpBarBackground)

        hpBarFill.strokeColor = .clear
        hpBarFill.zPosition = 7
        hpBarBackground.addChild(hpBarFill)

        hpBarHighlight.fillColor = SKColor(white: 1, alpha: 0.25)
        hpBarHighlight.strokeColor = .clear
        hpBarHighlight.zPosition = 8
        let highlightRect = CGRect(x: -hpBarWidth / 2, y: 1, width: hpBarWidth, height: 4)
        hpBarHighlight.path = CGPath(roundedRect: highlightRect, cornerWidth: 2, cornerHeight: 2, transform: nil)
        hpBarBackground.addChild(hpBarHighlight)

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
        hpBarFill.fillColor = clamped > 0.3
            ? SKColor(red: 0.86, green: 0.22, blue: 0.30, alpha: 1)
            : SKColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1)
        hpBarHighlight.isHidden = clamped <= 0
    }

    private func setBackdropHue(_ hue: Double) {
        backdrop.texture = Self.makeBackdropTexture(hue: CGFloat(hue))
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

    private func configureEmberEmitter() {
        emberEmitter.particleTexture = Self.makeGlowTexture()
        emberEmitter.position = CGPoint(x: 0, y: -size.height / 2)
        emberEmitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emberEmitter.particleBirthRate = 3.5
        emberEmitter.particleLifetime = 5
        emberEmitter.particleLifetimeRange = 2
        emberEmitter.emissionAngle = .pi / 2
        emberEmitter.emissionAngleRange = .pi / 10
        emberEmitter.particleSpeed = 16
        emberEmitter.particleSpeedRange = 10
        emberEmitter.xAcceleration = 0
        emberEmitter.yAcceleration = 4
        emberEmitter.particleAlpha = 0.55
        emberEmitter.particleAlphaRange = 0.3
        emberEmitter.particleAlphaSpeed = -0.13
        emberEmitter.particleScale = 0.55
        emberEmitter.particleScaleRange = 0.3
        emberEmitter.particleScaleSpeed = -0.09
        emberEmitter.particleColor = SKColor(red: 1.0, green: 0.75, blue: 0.45, alpha: 1)
        emberEmitter.particleColorBlendFactor = 1
        emberEmitter.particleBlendMode = .add
        emberEmitter.zPosition = -5
        addChild(emberEmitter)
    }

    /// Renders a small vertical-gradient texture (dark near-black at the
    /// bottom, a muted hue-tinted glow near the top) used as the battle
    /// stage backdrop for the given zone.
    private static func makeBackdropTexture(hue: CGFloat) -> SKTexture {
        let size = CGSize(width: 64, height: 96)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let topColor = UIColor(hue: hue, saturation: 0.5, brightness: 0.30, alpha: 1)
            let bottomColor = UIColor(hue: hue, saturation: 0.55, brightness: 0.07, alpha: 1)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else { return }
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width / 2, y: 0),
                end: CGPoint(x: size.width / 2, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }

    /// A small soft radial blob used as the ember particle texture.
    private static func makeGlowTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.withAlphaComponent(0.9).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else { return }
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                startRadius: 0,
                endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                endRadius: size.width / 2,
                options: []
            )
        }
        return SKTexture(image: image)
    }
}
