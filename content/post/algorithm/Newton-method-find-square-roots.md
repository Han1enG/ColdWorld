---
title: 牛顿法求解平方根
date: 2023-05-16 12:50:15
tags:
  - Algrithm
  - Math
categories: Technology
---

![牛顿法](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20240219231230.gif)

假设输入的数是 $m$，则其实是求一个 $ x $ 值，使其满足 $x^2 = m$，令 $f(x) = x^2 - m$ ，其实就是求方程 $f(x) = 0$ 的根。那么 $f(x)$ 的导函数是 $f'(x) = 2x$。
如果是二次函数的话，是很简单的导数运算，切线方程：$y=f′(x_n)(x−x_n)+f(x_n)$，求交点就是把 $y$ 置为零。

```go
package main

import (
	"fmt"
	"math"
)

const err float64 = 1e-8 // err 是允许的误差

func Sqrt(x float64) float64 {
	if x < 0 {
		return -1
	}
	root := 1.0
	for math.Abs(x - root * root) >= err {
		root -= (root * root - x) / (2 * root)
	}
	return root
}

func main() {
	fmt.Println(Sqrt(2))
}
```
