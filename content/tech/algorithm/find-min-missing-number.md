---
title: 查找数组中缺失的最小正整数 O(n)
date: 2024-07-10 13:59:07
tags:
  - Algorithm
  - Math
categories: Algorithm
katex: true
---

```go
// findSmallestMissingNumber 查找数组中缺失的最小正整数
func findSmallestMissingNumber(nums []int) int {
	n := len(nums)

	// 遍历数组，将每个数字放到它应该在的位置上
	for i := 0; i < n; i++ {
		for nums[i] > 0 && nums[i] <= n && nums[nums[i]-1] != nums[i] {
			nums[i], nums[nums[i]-1] = nums[nums[i]-1], nums[i]
		}
	}

	// 再次遍历数组，找到第一个不在正确位置上的数字
	for i := 0; i < n; i++ {
		if nums[i] != i + 1 {
			return i + 1
		}
	}

	// 如果数组中的数字是从 1 到 n 的连续数字，则最小的缺失数字是 n+1
	return n + 1
}
```
