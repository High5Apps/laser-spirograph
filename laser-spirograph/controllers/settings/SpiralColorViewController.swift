//
//  SpiralColorViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/30/21.
//

import UIKit
import CoreData.NSManagedObjectContext

class SpiralColorViewController: UIViewController {
    
    // MARK: Properties
    
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var colors: [UIColor] = Self.defaultColors
    
    private static let itemsPerRow = 4
    private static let margin: CGFloat = 16
    private static let defaultColors: [UIColor] = [
        UIColor.LSColors.Green532Nanometers,
        UIColor.LSColors.Red638Nanometers,
        UIColor.LSColors.Yellow593Nanometers,
        UIColor.LSColors.Blue450Nanometers,
        UIColor.LSColors.Blue473Nanometers,
        UIColor.LSColors.Blue488Nanometers,
        UIColor.LSColors.Purple405Nanometers,
    ]
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: Self.margin, left: Self.margin, bottom: Self.margin, right: Self.margin)
        
        setInitialColor()
    }
    
    private func setInitialColor() {
        var selectedColorIndex = 0
        if let context = managedObjectContext {
            let selectedColor = LSColorProvider.shared(context: context).primaryColor
            if let selectedIndex = colors.firstIndex(of: selectedColor) {
                selectedColorIndex = selectedIndex
            }
        }
        
        let selectedIndexPath = IndexPath(item: selectedColorIndex, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let rowWidth = collectionView.frame.size.width
        let itemWidth = (rowWidth - CGFloat(Self.itemsPerRow + 1) * Self.margin) / CGFloat(Self.itemsPerRow)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumLineSpacing = Self.margin
        flowLayout.minimumInteritemSpacing = Self.margin
    }
}

// MARK: UICollectionViewDataSource

extension SpiralColorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LSColorChipCollectionView", for: indexPath)
        
        if let colorChip = item as? LSColorChipCollectionViewCell {
            colorChip.color = colors[indexPath.item]
        }
                        
        return item
    }
}

extension SpiralColorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = colors[indexPath.item]
        view.window?.tintColor = selectedColor

        guard let context = managedObjectContext else { return }
        let sharedColorProvider = LSColorProvider.shared(context: context)
        sharedColorProvider.primaryColor = selectedColor
        sharedColorProvider.save()
    }
}
