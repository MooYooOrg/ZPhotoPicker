//
//  ZPhotoSinglePickerController.swift
//
//  Created by Zack･Zheng on 2018/1/31.
//

import UIKit

class ZPhotoSinglePickerController: UINavigationController {
    
    private var imagePickedHandler: ((_ image: UIImage) -> Void)?
    private var cancelledHandler: (() -> Void)?
    private var allowsCropping: Bool = false

    deinit {
        print("\(self) \(#function)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(allowsCropping: Bool = false, imagePickedHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoAlbumListController()
        self.init(rootViewController: vc)
        self.allowsCropping = allowsCropping
        self.imagePickedHandler = imagePickedHandler
        self.cancelledHandler = cancelledHandler
        vc.albumListdelegate = self
        let secondVC = ZPhotoSinglePickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        secondVC.delegate = self
        self.pushViewController(secondVC, animated: false)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZPhotoSinglePickerController {
    
    class func pickPhoto(onPresentingViewController controller: UIViewController, allowsCropping: Bool = false, imageTookHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoSinglePickerController(allowsCropping: allowsCropping, imagePickedHandler: imageTookHandler, cancelledHandler: cancelledHandler)
        vc.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    class func pickPhoto(onPresentingViewController controller: UIViewController, allowsCropping: Bool = false, imageTookHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil, userInterfaceStyle: UIUserInterfaceStyle = .unspecified) {

        let vc = ZPhotoSinglePickerController(allowsCropping: allowsCropping, imagePickedHandler: imageTookHandler, cancelledHandler: cancelledHandler)
        if #available(iOS 13.0, *) {
            vc.overrideUserInterfaceStyle = userInterfaceStyle
        }
        vc.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZPhotoSinglePickerController: ZPhotoSinglePickerHostControllerDelegate {

    func photoSinglePickerHostController(_ controller: ZPhotoSinglePickerHostController, didFinishPickingImage image: UIImage) {

        if allowsCropping {
            
            let vc = ZPhotoCropperController()
            vc.cancelledHandler = { [weak vc] in
                vc?.dismiss(animated: true)
            }
            vc.image = image
            vc.imageCroppedHandler = { [weak vc] image in

                vc?.dismiss(animated: false) { [weak self] in

                    self?.dismiss(animated: true) { [weak self] in
                        self?.imagePickedHandler?(image)
                    }
                }
            }
            vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            vc.transitioningDelegate = vc
            present(vc, animated: true)

        } else {

            dismiss(animated: true) { [weak self] in
                self?.imagePickedHandler?(image)
            }
        }
    }
    
    func photoSinglePickerHostControllerDidCancel(_ controller: ZPhotoSinglePickerHostController) {
        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }
}

extension ZPhotoSinglePickerController: ZPhotoAlbumListControllerDelegate {

    func photoAlbumListController(_ controller: ZPhotoAlbumListController, didSelectAlbum album: AlbumItem) {

        let vc = ZPhotoSinglePickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.delegate = self
        vc.selectedAlbum = album
        pushViewController(vc, animated: true)
    }
    
    func photoAlbumListControllerDidCancel(_ controller: ZPhotoAlbumListController) {

        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }
}
