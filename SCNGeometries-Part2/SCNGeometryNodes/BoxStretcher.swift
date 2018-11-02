//
//  BoxStretcher.swift
//  SCNGeometries-Part2
//
//  Created by Max Cobb on 30/10/2018.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit

private func *(lhs: SCNVector3, rhs: CGFloat) -> SCNVector3 {
	return lhs * Float(rhs)
}
private func *(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
	return SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
}


class BoxStretch: SCNNode {
	var vertices: [SCNVector3]
	var timer: Timer? = nil
	var indices: SCNGeometryElement
	var calculatedPositions: [CGFloat] = []
	var material = SCNMaterial()
	/// Create a cuboid that will automatically strech random vertices every 3 seconds
	///
	/// - Parameters:
	///   - width: The width of the cuboid along the x-axis of its local coordinate space.
	///   - height: The height of the cuboid along the y-axis of its local coordinate space
	///   - length: The length of the box along the z-axis of its local coordinate space
	///   - diffuse: The visual contents of the material property—a color, image, or source of animated content.
	init(width: CGFloat, height: CGFloat, length: CGFloat, diffuse: Any? = UIColor.white) {
		let (verts, inds) = SCNGeometry.BoxParts(width: width, height: height, length: length)
		self.indices = inds
		self.vertices = verts
		super.init()
		self.preCalculatePositions(count: 150)
		self.material.diffuse.contents = diffuse
		self.updateGeometry()
		self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (time) in
			self.chooseCornerPull()
		})
	}

	/// Update the geometry of this node with the vertices and indices
	private func updateGeometry() {
		let src = SCNGeometrySource(vertices: self.vertices)
		let geo = SCNGeometry(sources: [src], elements: [self.indices])
		geo.materials = [self.material]
		self.geometry = geo
	}

	/// Chooses a random vertex and runs the animation on it
	///
	/// - Parameter corner: if you wanted to choose a specific corner, use the parameter
	func chooseCornerPull(corner: Int? = nil) {
		self.removeAllActions()
		let myCorner = corner ?? Int.random(in: 0..<8)
		let startPos = self.vertices[myCorner]
		self.runAction(SCNAction.customAction(duration: 3) { (_, elapsedTime) in
//			self.animateCorner(index: myCorner, startPos: startPos, elapsedTime: elapsedTime)
			self.animateCornerPrecalc(index: myCorner, startPos: startPos, elapsedTime: elapsedTime)
		}) {
			// Completion block, making sure the vertex is put in the
			// original place at the end
			self.vertices[myCorner] = startPos
		}
	}

	/// Pre-calculate all the positions for a faster animation
	///
	/// - Parameter count: how many points to pre-calculate, default 100.
	///   If you put more than 180 then you won't see much difference
	///	  180 frames = 60 fps for 3 seconds
	private func preCalculatePositions(count: Int = 100) {
		var vals: [CGFloat] = [CGFloat].init(repeating: 1, count: count)
		for n in 0..<count {
			// this will get a number from [0-3]
			let tNow = CGFloat(n * 3) / CGFloat(count - 1)
			vals[n] = self.getTNow(with: tNow)
		}
		self.calculatedPositions = vals
	}

	/// Update the position for the given vertex when a given time has passed
	///
	/// - Parameters:
	///   - index: index in the vertices array to update
	///   - startPos: resting position of the vertex
	///   - elapsedTime: time since the animation started
	private func animateCorner(index: Int, startPos: SCNVector3, elapsedTime: CGFloat) {
		let tNow = getTNow(with: elapsedTime)
		self.vertices[index] = startPos * (1 + tNow)
		self.updateGeometry()
	}

	/// Calculate the interpolation value given a time progression [0-3]
	///
	/// - Parameter time: time since animation started [0-3]
	/// - Returns: interpolation to be applied to the vector
	private func getTNow(with time: CGFloat) -> CGFloat {
		if time < 0.5 {
			return 1 - (1/(2*time + 1))
		} else {
			return (sin(5 * time * CGFloat.pi) / 2) * exp(-5 * (time - 0.5))
		}
	}

	/// Use the precalculated positions to animate the vertex
	///
	/// - Parameters:
	///   - index: index in the vertices array to update
	///   - startPos: resting position of the vertex
	///   - elapsedTime: time since the animation started
	private func animateCornerPrecalc(index: Int, startPos: SCNVector3, elapsedTime: CGFloat) {
		let tNow = getTNowPrecalc(at: elapsedTime / 3)
		self.vertices[index] = startPos * (1 + tNow)
		self.updateGeometry()
	}

	/// Get the value from self.calculatedPositions
	///
	/// - Parameter at: a value from [0-1] representing progression
	/// - Returns: CGFloat that we want for the animation
	private func getTNowPrecalc(at: CGFloat) -> CGFloat {
		let sz = self.calculatedPositions.count
		let percent = min(max(at, 0), 1) // ensure we have a value [0-1]
		let index = Int(percent * CGFloat(sz - 1)) // if sz = 100, we now have [0-99]
		return self.calculatedPositions[index]
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
