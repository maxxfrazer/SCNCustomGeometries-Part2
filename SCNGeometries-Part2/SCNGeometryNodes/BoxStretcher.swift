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
	let tStart = Date()
	var vertices: [SCNVector3]
	var timer: Timer? = nil
	var pingTimer: Timer? = nil
	var indices: SCNGeometryElement
	var calculatedPositions: [CGFloat] = []
	var material = SCNMaterial()
	init(width: CGFloat, height: CGFloat, length: CGFloat, diffuse: Any? = UIColor.white) {
		let (verts, inds) = SCNGeometry.BoxParts(width: width, height: height, length: length)
		self.indices = inds
		self.vertices = verts
		super.init()
		self.preCalculatePositions(count: 150)
		self.material.diffuse.contents = diffuse
		updateGeometry()
		timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (time) in
			self.chooseCornerPull()
		})
	}

	func updateGeometry() {
		let src = SCNGeometrySource(vertices: self.vertices)
		let geo = SCNGeometry(sources: [src], elements: [self.indices])
		geo.materials = [self.material]
		self.geometry = geo
	}

	func chooseCornerPull() {
		let myCorner = Int.random(in: 0..<8)
		let startPos = self.vertices[myCorner]
		self.runAction(SCNAction.customAction(duration: 3) { (_, timeElapsed) in
//			self.animateCorner(index: myCorner, startPos: startPos, timeElapsed: timeElapsed)
			self.animateCornerPrecalc(index: myCorner, startPos: startPos, timeElapsed: timeElapsed)
		}) {
			// Completion block, making sure the vertex is put in the
			// original place at the end
			self.vertices[myCorner] = startPos
		}
	}

	func preCalculatePositions(count: Int = 100) {
		var vals: [CGFloat] = [CGFloat].init(repeating: 1, count: count)
		for n in 0..<count {
			// this will get a number from [0-3]
			let tNow = CGFloat(n * 3) / CGFloat(count - 1)
			vals[n] = self.getTNow(with: tNow)
		}
		self.calculatedPositions = vals
	}

	func animateCorner(index: Int, startPos: SCNVector3, timeElapsed: CGFloat) {
		let tNow = getTNow(with: timeElapsed)
		self.vertices[index] = startPos * (1 + tNow)
		self.updateGeometry()
	}

	func getTNow(with time: CGFloat) -> CGFloat {
		if time < 0.5 {
			return 1 - (1/(2*time + 1))
		} else {
			return (sin(5 * time * CGFloat.pi) / 2) * exp(-5 * (time - 0.5))
		}
	}


	func animateCornerPrecalc(index: Int, startPos: SCNVector3, timeElapsed: CGFloat) {
		let tNow = getTNowPrecalc(at: timeElapsed / 3)
		self.vertices[index] = startPos * (1 + tNow)
		self.updateGeometry()
	}

	/// Get the value from self.calculatedPositions
	///
	/// - Parameter at: a value from [0-1] representing progression
	/// - Returns: CGFloat that we want for the animation
	func getTNowPrecalc(at: CGFloat) -> CGFloat {
		let sz = self.calculatedPositions.count
		let percent = min(max(at, 0), 1) // ensure we have a value [0-1]
		let index = Int(percent * CGFloat(sz - 1)) // if sz = 100, we now have [0-99]
		return self.calculatedPositions[index]
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
