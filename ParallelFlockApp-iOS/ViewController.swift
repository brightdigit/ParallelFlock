import ParallelFlock
import UIKit

class ViewController: UIViewController {
  @IBOutlet var completedLabel: UILabel!
  @IBOutlet var runningLabel: UILabel!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
  var operation: ParallelMapOperation<Void, Void>?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    let source = [Void].init(repeating: Void(), count: 100_000)
    self.operation = source.parallel.map({
      $1(Void())
    }, completion: self.onOperationCompletion)
  }

  func onOperationCompletion(_: [Void]) {
    self.operation = nil
    DispatchQueue.main.async {
      self.activityIndicatorView.stopAnimating()
      self.completedLabel.isHidden = false
      self.runningLabel.isHidden = true
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
