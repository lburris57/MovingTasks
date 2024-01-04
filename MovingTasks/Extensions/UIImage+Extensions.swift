//
//  UIImage+Extensions.swift
//
//  Created by Mohammad Azam on 5/19/23.
//
import UIKit

extension UIImage
{
    func resizeTo(to size: CGSize) -> UIImage
    {
        return UIGraphicsImageRenderer(size: size).image
        { 
            _ in
            
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
