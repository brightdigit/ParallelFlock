import ParallelFlock
import UIKit

class ViewController: UIViewController {
  @IBOutlet var completedLabel: UILabel!
  @IBOutlet var runningLabel: UILabel!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
  var startTime: Date?
  var endTime: Date?

  #if USE_PARALLEL
    var operation: ParallelMapOperation<Void, Void>?
  #endif

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  func startActivity() {
    let source = [Void].init(repeating: Void(), count: 10000)
    self.startTime = Date()
    #if USE_PARALLEL
      self.operation = source.parallel.map({
        $1(Void())
      }, completion: self.onOperationCompletion)
    #else
      _ = source.map { Void() }
      self.endActivity()
    #endif
  }

  func endActivity() {
    self.endTime = Date()
    self.activityIndicatorView.stopAnimating()
    self.completedLabel.isHidden = false
    self.runningLabel.isHidden = true
    if let startTime = self.startTime, let endTime = self.endTime {
      let timeInterval = endTime.timeIntervalSince(startTime)
      self.completedLabel.text = "Completed in \(timeInterval)"
    }
  }

  #if USE_PARALLEL
    func onOperationCompletion(_: [Void]) {
      self.operation = nil
      self.endTime = Date()
      DispatchQueue.main.async(execute: self.endActivity)
    }
  #endif

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
