---
title: 圆拟合
date: 2024-06-05 09:59:07
tags:
  - Algorithm
  - Math
categories: Algorithm
katex: true
---

### 1. 最小二乘法

推导过程可参考 [Kåsa Fit](https://blog.csdn.net/lingtianyulong/article/details/105015386) 算法：

```go
// fitCenterByLeastSquare 最小二乘法拟合圆
func fitCenterByLeastSquare(points []gocv.Point2f) (gocv.Point2f, float32) {
	var sumX, sumY, sumX2, sumY2, sumXY, sumX3, sumY3, sumX2Y, sumY2X float32
	for _, p := range points {
		sumX += p.X
		sumY += p.Y
		sumX2 += p.X * p.X
		sumY2 += p.Y * p.Y
		sumXY += p.X * p.Y
		sumX3 += p.X * p.X * p.X
		sumY3 += p.Y * p.Y * p.Y
		sumX2Y += p.X * p.X * p.Y
		sumY2X += p.Y * p.Y * p.X
	}
	N := float32(len(points))
	C := N*sumX2 - sumX*sumX
	D := N*sumXY - sumX*sumY
	E := N*(sumX3+sumY2X) - sumX*(sumX2+sumY2)
	G := N*sumY2 - sumY*sumY
	H := N*(sumX2Y+sumY3) - sumY*(sumX2+sumY2)
	a := (H*D - E*G) / (C*G - D*D)
	b := (H*C - E*D) / (D*D - G*C)
	c := -(a*sumX + b*sumY + sumX2 + sumY2) / N

	centerX := -a / 2
	centerY := -b / 2
	radius := math.Sqrt(float64(a*a+b*b-4*c)) / 2

	return gocv.Point2f{X: centerX, Y: centerY}, float32(radius)
}
```
