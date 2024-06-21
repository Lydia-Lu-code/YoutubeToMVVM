import UIKit
import Photos

class AddVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddVC viewDidLoad 被呼叫了")
        view.backgroundColor = .systemBackground

//        // 配置ADD鍵的外觀
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .plain, target: self, action: #selector(addButtonTapped))
        
        // 直接檢查相簿許可權並顯示照片選擇器
        checkPhotoLibraryPermission()
        
//        // 配置ADD鍵的外觀
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .plain, target: self, action: #selector(addButtonTapped))
    }
    
    @objc func addButtonTapped() {
        checkPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            showPhotoPicker()
        case .denied, .restricted:
            print("AddVC 相簿訪問權限已被拒絕或受限制。請在設置中啟用相簿訪問權限。")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.showPhotoPicker()
                    } else {
                        print("AddVC 用戶未授予相簿訪問權限。")
                    }
                }
            }
        @unknown default:
            fatalError("AssVC Unexpected case when checking photo library permission.")
        }
    }

    
    func showPhotoPicker() {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension AddVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 在這裡處理選擇的照片
        if let pickedImage = info[.originalImage] as? UIImage {
            // 在這裡使用選擇的照片進行後續處理
            print("Add 成功選擇了照片")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



