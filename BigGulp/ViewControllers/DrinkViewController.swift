import UIKit

class DrinkViewController: UIViewController, UIAlertViewDelegate {

    @IBOutlet weak var progressMeter: DPMeterView!
    @IBOutlet weak var percentageLabel: UICountingLabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var smallButton: UIButton!
    @IBOutlet weak var largeButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet var entryHandler: EntryHandler!
    let userDefaults = NSUserDefaults.groupUserDefaults()
    var expanded = false
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Drink!"   

        initAnimation()

        self.percentageLabel.animationDuration = 1.5
        self.percentageLabel.format = "%d%%";
        self.progressMeter.startGravity()

        self.wormhole.listenForMessageWithIdentifier("watchUpdate", listener: { (_) -> Void in
            self.updateUI()
        })
        self.wormhole.listenForMessageWithIdentifier("todayUpdate", listener: { (_) -> Void in
            self.updateUI()
        })

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.progressMeter.setShape(ProgressMeter.pathFromRect(self.progressMeter.frame))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func updateCurrentEntry(delta: Double) {
        self.entryHandler.addGulp(delta)
        self.wormhole.passMessageObject("update", identifier: "mainUpdate")
        updateUI()
    }

    func updateUI() {
        self.percentageLabel.countFromCurrentValueTo(Float(ceil(self.entryHandler.currentEntry().percentage)))
        self.progressMeter.setProgress(CGFloat(self.entryHandler.currentEntry().percentage / 100.0), duration: 2)
    }

    @IBAction func addButtonAction(sender: UIButton) {
        if (self.expanded) {
            contractAddButton()
        } else {
            expandAddButton()
        }
    }

    @IBAction func selectionButtonAction(sender: UIButton) {
        contractAddButton()
        if (!self.userDefaults.boolForKey("UNDO_HINT")) {
            self.userDefaults.setBool(true, forKey: "UNDO_HINT")
            self.userDefaults.synchronize()
            AMPopTip.appearance().popoverColor = UIColor.mainColor()
            AMPopTip.appearance().offset = 10
            let popTip = AMPopTip()
            popTip.showText("Tap here to undo your latest action", direction: .Down, maxWidth: 200, inView: self.view, fromFrame: self.minusButton.frame)
        }
        if (self.smallButton == sender) {
            updateCurrentEntry(self.userDefaults.doubleForKey(Settings.Gulp.Small.key()))
        } else {
            updateCurrentEntry(self.userDefaults.doubleForKey(Settings.Gulp.Big.key()))
        }
    }

    @IBAction func removeGulpAction() {
        let alert = UIAlertView(title: "Undo", message: "Undo latest action?", delegate: self, cancelButtonTitle:"No", otherButtonTitles:"Yes")
        alert.show()
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex > 0) {
            self.entryHandler.removeLastGulp()
            updateUI()
        }
    }
}
