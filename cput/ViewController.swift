//
//  cput
//
//  Created by Jim Raynor on 2016/11/15.
//  Copyright © 2016 para. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var textfield_pid: NSTextField!
    @IBOutlet weak var textfield_percent: NSTextField!
    
    
    @IBAction func start_clicked(_ sender: Any) {
        var pid:pid_t = 34335;
        CpuT.start_cput(pid, throttle: 20);
    }
    
    @IBAction func stop_clicked(_ sender: Any) {
        CpuT.stop_cput()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

