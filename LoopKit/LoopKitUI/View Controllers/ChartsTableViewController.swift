import Combine
import HealthKit
import UIKit

/// Abstract class providing boilerplate setup for chart-based table view controllers
open class ChartsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    public var displayGlucosePreference: DisplayGlucosePreference? {
        didSet {
            guard let displayGlucosePreference = displayGlucosePreference else { return }

            displayGlucosePreference.$unit
                .sink { [weak self] displayGlucoseUnit in self?.unitPreferencesDidChange(to: displayGlucoseUnit) }
                .store(in: &cancellables)
        }
    }

    private lazy var cancellables = Set<AnyCancellable>()

    override open func viewDidLoad() {
        super.viewDidLoad()

        if let unit = displayGlucosePreference?.unit {
            charts.setGlucoseUnit(unit)
        }

        let gestureRecognizer = UILongPressGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.3
        gestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        charts.gestureRecognizer = gestureRecognizer

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification, object: nil)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.active = true
                if self?.visible == true {
                    self?.reloadData()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification, object: nil)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.active = false
            }
            .store(in: &cancellables)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        if !visible {
            charts.didReceiveMemoryWarning()
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        visible = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        visible = false
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        reloadData(animated: false)
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        charts.traitCollection = traitCollection
    }

    // MARK: - State

    // This function should only be called from the main thread
    public func unitPreferencesDidChange(to unit: HKUnit?) {
        if let unit = unit {
            charts.setGlucoseUnit(unit)
            glucoseUnitDidChange()
        }
        reloadData()
    }

    open func glucoseUnitDidChange() {
        // To override.
    }

    open func createChartsManager() -> ChartsManager {
        fatalError("Subclasses must implement \(#function)")
    }

    public private(set) lazy var charts = createChartsManager()

    // References to registered notification center observers
    public var notificationObservers: [Any] = []

    open var active: Bool = true {
        didSet {
            reloadData()
        }
    }

    public var visible = false {
        didSet {
            reloadData()
        }
    }

    // MARK: - Data loading

    /// Refetches all data and updates the views. Must be called on the main queue.
    ///
    /// - Parameters:
    ///   - animated: Whether the updating should be animated if possible
    open func reloadData(animated _: Bool = false) {}

    // MARK: - UIGestureRecognizer

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        /// Only start the long-press recognition when it starts in a chart cell
        let point = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            if let cell = tableView.cellForRow(at: indexPath), cell is ChartTableViewCell {
                return true
            }
        }

        return false
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }

    @objc func handlePan(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed,
             .possible:
            // Follow your dreams!
            break
        case .began,
             .cancelled,
             .ended,
             .failed:
            for case let row as ChartTableViewCell in tableView.visibleCells {
                let forwards = gestureRecognizer.state == .began
                UIView.animate(withDuration: forwards ? 0.2 : 0.5, delay: forwards ? 0 : 1, animations: {
                    let alpha: CGFloat = forwards ? 0 : 1
                    row.titleLabel?.alpha = alpha
                    row.subtitleLabel?.alpha = alpha
                })
            }
        @unknown default:
            break
        }
    }
}

private extension ChartsManager {
    func setGlucoseUnit(_ unit: HKUnit) {
        for case let chart as GlucoseChart in charts {
            chart.glucoseUnit = unit
        }
    }
}
