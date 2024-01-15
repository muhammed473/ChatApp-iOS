//
//  PhotoViewerViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

    private let url : URL
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView : UIImageView = {
        let myImageView = UIImageView()
        myImageView.contentMode = .scaleAspectFit
        return myImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fotoğraf"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.sd_setImage(with: self.url,completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        imageView.frame = view.bounds
    }
    
}
