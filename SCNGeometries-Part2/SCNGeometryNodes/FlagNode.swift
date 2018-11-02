//
//  FlagNode.swift
//  SCNGeometries-Part2
//
//  Created by Max Cobb on 30/10/2018.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit

class FlagNode: SCNNode {
	private var xyCount: CGSize
	private var vertices: [SCNVector3]
	private var timer: Timer? = nil
	private var indices: SCNGeometryElement
	var material = SCNMaterial()
	private var textureCoord: SCNGeometrySource
	private var flagAction: SCNAction!
	/// Create a plane of width, height, vertex count and material diffuse
	///
	/// - Parameters:
	///   - frameSize: physical width and height of the geometry
	///   - xyCount: number of horizontal and vertical vertices
	///   - diffuse: diffuse to be applied to the geometry; a color, image, or source of animated content.
	public init(frameSize: CGSize, xyCount: CGSize, diffuse: Any? = UIColor.white) {
		let (verts, textureMap, inds) = SCNGeometry.PlaneParts(size: frameSize, xyCount: xyCount)
		self.xyCount = xyCount
		self.textureCoord = textureMap
		self.indices = inds
		self.vertices = verts
		super.init()
		self.updateGeometry()
		self.flagAction = SCNAction.customAction(duration: 100000) { (_, elapsedTime) in
			// using duration: Double.infinity or Double.greatestFiniteMagnitude breaks `elapsedTime`
			// I'll try find some alternative that's nicer than `100000` later
			self.animateFlagXY(elapsedTime: elapsedTime)
		}
		self.material.diffuse.contents = diffuse
		self.runAction(SCNAction.repeatForever(self.flagAction))
	}

	/// Update the geometry of this node with the vertices, texture coordinates and indices
	private func updateGeometry() {
		let src = SCNGeometrySource(vertices: vertices)
		let geo = SCNGeometry(sources: [src, self.textureCoord], elements: [self.indices])
		geo.materials = [self.material]
		self.geometry = geo
	}

	// I appreciate the next few functions are not very DRY, it's annoying me (author)
	// but am keeping the math clear for the tutorial

	/// Wave the flag using just the x coordinate
	///
	/// - Parameter elapsedTime: time since animation started [0-duration] in seconds
	private func animateFlag(elapsedTime: CGFloat) {
		let yCount = Int(xyCount.height)
		let xCount = Int(xyCount.width)
		let furthest = Float((yCount - 1) + (xCount - 1))
		let tNow = elapsedTime
		let waveScale = Float(0.1 * (min(tNow / 10, 1)))
		for x in 0..<xCount {
			let distance = Float(x) / furthest
			let newZ = waveScale * (sinf(15 * (Float(tNow) - distance)) * distance)
			// only the x position is effecting the translation here,
			// that's why we calculate before going to the second while loop
			for y in 0..<yCount {
				self.vertices[y * xCount + x].z = newZ
			}
		}
		self.updateGeometry()
	}

	/// Wave the flag, using x and y coordinates
	///
	/// - Parameter elapsedTime: time since animation started [0-duration] in seconds
	private func animateFlagXY(elapsedTime: CGFloat) {
		let yCount = Int(xyCount.height)
		let xCount = Int(xyCount.width)
		let furthest = Float((yCount - 1) + (xCount - 1))
		let tNow = elapsedTime
		let waveScale = Float(0.1 * (min(tNow / 10, 1)))
		for x in 0..<xCount {
			let distanceX = Float(x) / furthest
			for y in 0..<yCount {
				let distance = distanceX + Float(y) / furthest
				let newZ = waveScale * (sinf(15 * (Float(tNow) - distance)) * distanceX)
				self.vertices[y * xCount + x].z = newZ
			}
		}
		self.updateGeometry()
	}

	/// Wave the flag looks a little crazy but interesting to watch
	///
	/// - Parameter elapsedTime: time since animation started [0-duration] in seconds
	private func animateFlagMadness(elapsedTime: CGFloat) {
		let yCount = Int(xyCount.height)
		let xCount = Int(xyCount.width)
		let furthest = sqrt(Float((yCount - 1)*(yCount - 1) + (xCount - 1)*(xCount - 1)))
		let tNow = elapsedTime
		let waveScale = Float(0.1 * (min(tNow / 10, 1)))
		for x in 0..<xCount {
			let distanceX = Float(x) / Float(xCount - 1)
			for y in 0..<yCount {
				let distance = Float(x * x + y * y) / furthest
				let newZ = waveScale * (sinf(15 * (Float(tNow) - distance)) * distanceX)
				self.vertices[y * xCount + x].z = newZ
			}
		}
		self.updateGeometry()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
