//
//  SCNGeometry+Extensions.swift
//  SCNGeometries-Part2
//
//  Created by Max Cobb on 30/10/2018.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit.SCNGeometry

extension SCNGeometry {
	/// Get the vertices, texture mapping and indices for a plane geometry
	///
	/// - Parameters:
	///   - size: how large you want the geometry
	///   - xyCount: how many vertices you want, in the width and in the height
	///     minimum of 2 for each
	/// - Returns: vertices, texture mapping and indices for your plane geometry
	static func PlaneParts(size: CGSize, xyCount: CGSize = CGSize(width: 2, height: 2)) -> ([SCNVector3], SCNGeometrySource, SCNGeometryElement) {
		var triPositions = [SCNVector3].init(repeating: SCNVector3Zero, count: Int(xyCount.width * xyCount.height))
		var yPos = size.height / 2
		let xStart = -size.width / 2
		var indices: [UInt32] = []
		var textureCoord: [CGPoint] = [CGPoint].init(repeating: CGPoint.zero, count: Int(xyCount.width * xyCount.height))
		for y in 0..<Int(xyCount.height) {
			for x in 0..<Int(xyCount.width) {
				triPositions[y * Int(xyCount.width) + x] = SCNVector3(xStart + size.width * CGFloat(x) / CGFloat(xyCount.width - 1), yPos, 0)
				textureCoord[y * Int(xyCount.width) + x] = CGPoint(x: CGFloat(x) / CGFloat(xyCount.width - 1), y: CGFloat(y) / CGFloat(xyCount.height - 1))
				if x > 0 && y > 0 {
					let currentCoord = CGFloat(y * Int(xyCount.width) + x)
					indices.append(contentsOf: [
						UInt32(currentCoord - xyCount.width - 1),
						UInt32(currentCoord - 1),
						UInt32(currentCoord - xyCount.width),
						UInt32(currentCoord - xyCount.width),
						UInt32(currentCoord - 1),
						UInt32(currentCoord)
						])
				}
			}
			yPos -= size.height / (xyCount.height - 1)
		}
		return (triPositions, SCNGeometrySource(textureCoordinates: textureCoord), SCNGeometryElement(indices: indices, primitiveType: .triangles))
	}

	/// Get the vertices, texture mapping and indices for a Cuboid
	///
	/// - Parameters:
	///   - width: The width of the cuboid along the x-axis of its local coordinate space.
	///   - height: The height of the cuboid along the y-axis of its local coordinate space.
	///   - length: The length of the cuboid along the z-axis of its local coordinate space.
	/// - Returns: vertices and indices for your cuboid geometry
	static func BoxParts(width: CGFloat, height: CGFloat, length: CGFloat) -> ([SCNVector3], SCNGeometryElement) {
		let w = width / 2
		let h = height / 2
		let l = length / 2
		let triPositions = [
			// bottom 4 vertices
			SCNVector3(-w, -h, -l),
			SCNVector3(w, -h, -l),
			SCNVector3(w, -h, l),
			SCNVector3(-w, -h, l),

			// top 4 vertices
			SCNVector3(-w, h, -l),
			SCNVector3(w, h, -l),
			SCNVector3(w, h, l),
			SCNVector3(-w, h, l),
			]
		let indices: [UInt32] = [
			// bottom face
			0, 1, 3,
			3, 1, 2,
			// left face
			0, 3, 4,
			4, 3, 7,
			// right face
			1, 5, 2,
			2, 5, 6,
			// top face
			4, 7, 5,
			5, 7, 6,
			// front face
			3, 2, 7,
			7, 2, 6,
			// back face
			0, 4, 1,
			1, 4, 5,
			]
		return (triPositions, SCNGeometryElement(indices: indices, primitiveType: .triangles))
	}

}
