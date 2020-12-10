import UIKit
import Photos

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView = UIImageView()
  lazy var selectedImageView = UIImageView()
  private var videoInfoView: VideoInfoView

  private let videoInfoBarHeight: CGFloat = 15
  var duration: TimeInterval? {
    didSet {
      if let duration = duration, duration > 0 {
        self.videoInfoView.duration = duration
        self.videoInfoView.isHidden = false
      } else {
        self.videoInfoView.isHidden = true
      }
    }
  }

  override init(frame: CGRect) {
    let videoBarFrame = CGRect(x: 0, y: frame.height - self.videoInfoBarHeight,
                               width: frame.width, height: self.videoInfoBarHeight)
    videoInfoView = VideoInfoView(frame: videoBarFrame)
    videoInfoView.isHidden = true
    super.init(frame: frame)

    for view in [imageView, selectedImageView, videoInfoView] as [UIView] {
      view.contentMode = .scaleAspectFill
      view.translatesAutoresizingMaskIntoConstraints = false
      view.clipsToBounds = true
      contentView.addSubview(view)
    }

    isAccessibilityElement = true
    accessibilityLabel = "Photo"

    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configureCell(_ asset: PHAsset, shouldPreferLowRes: Bool, selected: Bool) {
    selectedImageView.image = selected ? AssetManager.getImage("selectedImageGallery") : nil
    AssetManager.resolveAsset(asset, size: CGSize(width: 160, height: 240), shouldPreferLowRes: shouldPreferLowRes) { [weak self] image in
      guard let self = self, let image = image else {
        return
      }
      self.imageView.image = image
      self.duration = asset.duration
    }
  }
}
