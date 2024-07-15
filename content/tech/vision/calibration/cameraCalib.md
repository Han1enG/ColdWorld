---
title: 相机标定
date: 2024-06-14 09:53:07
tags:
  - Algorithm
  - Math
  - Vision
categories: Vision
katex: true
---

```go
// CalibCamera 标定相机
func CalibCamera(imgDatas [][]byte, chessboardRowCornerCount int, chessboardColCornerCount int, curImageIndex int) error {
	// 保存各图像中的角点的二维坐标, 即像素坐标
	imgPoints := gocv.NewPoints2fVector()
	defer imgPoints.Close()
	// 保存各图像中的角点的三维坐标，即世界坐标
	objPoints := gocv.NewPoints3fVector()
	defer objPoints.Close()
	// 保存图片尺寸
	imgSize := image.Point{X: 0, Y: 0}

	// 为三维点定义世界坐标系
	objectPoints := make([]gocv.Point3f, 0)
	for i := 0; i < chessboardColCornerCount; i++ {
		for j := 0; j < chessboardRowCornerCount; j++ {
			objectPoints = append(objectPoints, gocv.Point3f{X: float32(j), Y: float32(i), Z: 0})
		}
	}
	objPointsVector := gocv.NewPoint3fVectorFromPoints(objectPoints)
	defer objPointsVector.Close()

	// 1. 检测角点
	for index, imgData := range imgDatas {
		err := func() error {
			// 读取为灰度图
			grayImg, err := gocv.IMDecode(imgData, gocv.IMReadGrayScale)
			if err != nil {
				return err
			}
			if grayImg.Empty() {
				return nil
			}
			defer grayImg.Close()
			if index == 0 {
				imgSize = image.Point{X: grayImg.Cols(), Y: grayImg.Rows()}
			}
			// 保存图像二维角点信息
			corners := gocv.NewMat()
			defer corners.Close()
			// 如果在图像中找到所需数量的角点，返回true
			if found := gocv.FindChessboardCorners(grayImg, image.Pt(chessboardRowCornerCount, chessboardColCornerCount), &corners, gocv.CalibCBAdaptiveThresh|gocv.CalibCBFastCheck|gocv.CalibCBNormalizeImage); !found {
				return errors.New("Not Found Corner Points")
			}
			// 迭代算法中的终止条件(终止条件的类型、最大迭代次数、期望精度)
			criteria := gocv.NewTermCriteria(gocv.EPS|gocv.MaxIter, 30, 0.01)
			// 进一步提取亚像素角点，提高精度
			gocv.CornerSubPix(grayImg, &corners, image.Pt(11, 11), image.Pt(-1, -1), criteria)
			if corners.Cols()*corners.Rows() != chessboardColCornerCount*chessboardRowCornerCount {
				return errors.Newr("Not Matched Number Of Corner Points")
			}
			imagePoints := make([]gocv.Point2f, 0)
			// 注意corners矩阵只有一列，例如9*6的角点实际上是一个54*1的矩阵，因此不能在这里一起添加世界坐标
			for i := 0; i < corners.Rows(); i++ {
				for j := 0; j < corners.Cols(); j++ {
					pixelX, pixelY := corners.GetFloatAt(i, j*2), corners.GetFloatAt(i, j*2+1)
					imagePoints = append(imagePoints, gocv.Point2f{X: pixelX, Y: pixelY})
				}
			}
			// 添加像素坐标
			imgPointsVector := gocv.NewPoint2fVectorFromPoints(imagePoints)
			imgPoints.Append(imgPointsVector)
			imgPointsVector.Close()
			// 添加世界坐标
			objPoints.Append(objPointsVector)
			return nil
		}()
		if err != nil {
			return err
		}
	}

	// 2. 标定
	// 每幅图像的平移向量
	transMat := gocv.NewMat()
	defer transMat.Close()
	// 每幅图像的旋转向量
	rotMat := gocv.NewMat()
	defer rotMat.Close()
	// 相机内参矩阵 3*3
	cameraMatrix := gocv.NewMatWithSize(3, 3, gocv.MatTypeCV32F)
	defer cameraMatrix.Close()
	// 相机的5个畸变系数：k1,k2,p1,p2,k3 1*5
	distCoeffs := gocv.NewMat()
	defer distCoeffs.Close()
	res := gocv.CalibrateCamera(objPoints, imgPoints, imgSize, &cameraMatrix, &distCoeffs, &rotMat, &transMat, gocv.CalibFlag(0))

	// 3. 保存标定结果
	// 获取校正后的新相机矩阵
	newCameramtx, _ := gocv.GetOptimalNewCameraMatrixWithParams(cameraMatrix, distCoeffs, imgSize, 1, imgSize, false)
	defer newCameramtx.Close()
}
```

### Inspired by

[1] [相机畸变与标定](https://zhaoxuhui.top/blog/2018/04/17/CameraCalibration.html)
