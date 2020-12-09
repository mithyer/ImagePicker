import Foundation
import UIKit
import Photos

open class AssetManager {

  
  public static func getImage(_ name: String) -> UIImage {
    struct Consts {
      static let assetBundle: Bundle = {
        var bundle = Bundle(for: AssetManager.self)
        if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
          bundle = resourceBundle
        }
        return bundle
      }()
      static let traitCollection = UITraitCollection(displayScale: 3)
    }
    return UIImage(named: name, in: Consts.assetBundle, compatibleWith: Consts.traitCollection) ?? UIImage()
  }

  public static func fetch(withConfiguration configuration: Configuration, fetchAll: Bool = true, _ completion: @escaping (_ assets: [PHAsset], _ fetchedAll: Bool) -> Void) {
    guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }

    DispatchQueue.global(qos: .userInteractive).async {
      let options = PHFetchOptions()
      let fetchSomeLimitCount = 50
      if #available(iOS 9, *) {
        options.fetchLimit = fetchAll ? 0 : fetchSomeLimitCount
      }
      options.sortDescriptors = [NSSortDescriptor.init(key: "modificationDate", ascending: false)]
      let fetchResult = configuration.allowVideoSelection
        ? PHAsset.fetchAssets(with: options)
        : PHAsset.fetchAssets(with: .image, options:options)

      if fetchResult.count > 0 {
        let assets = fetchResult.objects(at: IndexSet.init(integersIn: 0..<fetchResult.count))
        DispatchQueue.main.async {
          completion(assets, fetchAll || fetchResult.count < fetchSomeLimitCount)
        }
      }
    }
  }

  public static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
    requestOptions.isNetworkAccessAllowed = true

    imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
      if let info = info, info["PHImageFileUTIKey"] == nil {
        DispatchQueue.main.async(execute: {
          completion(image)
        })
      }
    }
  }

  public static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    var images = [UIImage]()
    for asset in assets {
      imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
        if let image = image {
          images.append(image)
        }
      }
    }
    return images
  }
}
