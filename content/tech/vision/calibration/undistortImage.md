---
title: 畸变矫正
date: 2024-06-25 09:18:07
tags:
  - Algorithm
  - Math
  - Vision
categories: Vision
katex: true
---

```go
// UndistortImage 畸变校正
func UndistortImage(imgData []byte, imgSize image.Point, cameraMatrix gocv.Mat, distCoeffs gocv.Mat, newCameraMatrix gocv.Mat) ([]byte, error) {
	mapx := gocv.NewMatWithSize(imgSize.X, imgSize.Y, gocv.MatTypeCV32F)
	defer mapx.Close()
	mapy := gocv.NewMatWithSize(imgSize.X, imgSize.Y, gocv.MatTypeCV32F)
	defer mapy.Close()
	r := gocv.Eye(3, 3, gocv.MatTypeCV32F)
	defer r.Close()

	// 初始化校正映射
	gocv.InitUndistortRectifyMap(cameraMatrix, distCoeffs, r, newCameraMatrix, imgSize, int(gocv.MatTypeCV32F), mapx, mapy)
	// 保存校正后图像
	src, err := gocv.IMDecode(imgData, gocv.IMReadGrayScale)
	if err != nil {
		return nil, err
	}
	defer src.Close()
	dst := gocv.NewMat()
	defer dst.Close()
	gocv.Remap(src, &dst, &mapx, &mapy, gocv.InterpolationLinear, gocv.BorderConstant, color.RGBA{0, 0, 0, 0})

	// Mat 转 []byte
	imgBuf, err := gocv.IMEncode(".bmp", dst)
	if err != nil {
		return nil, i18n.WrapError(err, "Alg.Tag.EncodeImgFailed")
	}
	defer imgBuf.Close()
	// imgBuf 关闭后，外部使用此返回值会报错，需要拷贝一下
	b := make([]byte, imgBuf.Len())
	copy(b, imgBuf.GetBytes())

	return b, nil
}
```

### Inspired by

[1] [相机畸变与标定](https://zhaoxuhui.top/blog/2018/04/17/CameraCalibration.html)
