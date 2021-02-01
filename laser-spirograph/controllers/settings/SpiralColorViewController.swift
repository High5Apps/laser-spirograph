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
    
    private var colors = [UIColor]()
    
    private static let itemsPerRow = 4
    private static let margin: CGFloat = 16
    private static let nullColor: UIColor = .black
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
        
        colors.append(contentsOf: Self.defaultColors)
        colors.append(.secondarySystemBackground)

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
    
    private func onSelectedColor(_ color: UIColor) {
        view.window?.tintColor = color

        guard let context = managedObjectContext else { return }
        let sharedColorProvider = LSColorProvider.shared(context: context)
        sharedColorProvider.primaryColor = color
        sharedColorProvider.save()
    }
    
    private func addColor(_ color: UIColor) {
        let itemIndex = colors.count - 1
        colors.insert(color, at: itemIndex)
        collectionView.insertItems(at: [IndexPath(item: itemIndex, section: 0)])
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
            
            let isLastItem = (indexPath.item == colors.count - 1)
            colorChip.icon = isLastItem ? .plus : nil
        }
                        
        return item
    }
}

// MARK: UICollectionViewDelegate

extension SpiralColorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let chip = collectionView.cellForItem(at: indexPath) as? LSColorChipCollectionViewCell else { return true }
        if chip.icon == .plus {
            let colorPickerVC = UIColorPickerViewController()
            colorPickerVC.supportsAlpha = false
            colorPickerVC.selectedColor = Self.nullColor
            colorPickerVC.delegate = self
            present(colorPickerVC, animated: true)
        }
        
        return chip.icon == .none
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = colors[indexPath.item]
        onSelectedColor(selectedColor)
    }
}

// MARK: UIColorPickerViewControllerDelegate

extension SpiralColorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        guard selectedColor != Self.nullColor else { return }

        addColor(selectedColor)
        collectionView.selectItem(at: IndexPath(item: colors.count - 2, section: 0), animated: true, scrollPosition: [])
        onSelectedColor(selectedColor)
    }
}
