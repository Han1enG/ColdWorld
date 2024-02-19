---
title: Golang 基础语法
date: 2023-05-12 22:03:55
tags:
  - Golang
categories: Technology
---

### 环境搭建

VSCode 下载地址: https://code.visualstudio.com/

下载慢解决方法：

- 官网找到需要的版本后，点击下载，然后复制下载链接
- 将红框内地址更改为国内镜像地址 `vscode.cdn.azure.cn`

![img](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20210225152403740.png)

- 浏览器复制链接后重新下载

Golang 下载地址: https://golang.google.cn/dl/

1. VSCode 安装 Go 插件

2. 更新 Go 工具

    > 在更新之前需要说明的是，由于国内政策，没办法直接更新，需要代理

    ```bash
    # 旧版，已废弃
    go env -w GO111MODULE=on
    go env -w GOPROXY=https://goproxy.io,direct
    ```

    ```bash
    # 新版改成如下链接
    go env -w GO111MODULE=on
    go env -w GOPROXY=https://proxy.golang.com.cn,direct
    ```

    我这里报错`warning: go env -w GOPROXY=... does not override conflicting OS environment variable`原因是已经有一个了，查看了环境变量是PC前主人的，手动更改了环境变量，而后关掉并重新打开 VSCode，继续下面的步骤。

    - 在Visual Studio Code中，打开**命令面板**的**“帮助**>**显示所有命令**”。 或者使用键盘快捷方式 (Ctrl+Shift+P)
    - `Go: Install/Update tools`搜索 ，然后从托盘运行命令
    - 出现提示时，选择所有可用的 Go 工具，然后单击“确定”。
    - 等待 Go 工具完成更新。

    ![image-20230704104923435](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230704104923435.png)

    ![image-20230704104933532](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230704104933532.png)

    

### time

#### time.sleep

`golang` 的睡眠函数`time.sleep(1)`和`time.sleep(1 * time.Second)`

前者仅睡眠$1$纳秒，后者才是$1$秒

#### time.Now().Format("2006-01-02 15:04:05")

必须是这个时间点，才能格式化。

-----------------

### TrimRight(TrimLeft)

函数：`strings.TrimRight(s string, cutset string)`
定义：把`cutset`里面的字符串拆分成字符，然后从右往左，逐个比对字符串中的每个字符，直到遇到没有在`cutset`中出现的字符。

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	fmt.Println("aabbccdd\t:", strings.TrimLeft("aabbccdd", "abcd"))  // 空字符串
	fmt.Println("aabbccdde\t:", strings.TrimLeft("aabbccdde", "abcd")) // e
	fmt.Println("aabbeccdd\t:", strings.TrimLeft("aabbedcba", "abcd")) // edcba
	fmt.Println("aabbccdd\t:", strings.TrimRight("aabbccdd", "abcd"))  // 空字符串
	fmt.Println("aabbccdde\t:", strings.TrimRight("aabbccdde", "abcd")) // aabbccdde
	fmt.Println("aabbeccdd\t:", strings.TrimRight("aabbedcba", "abcd")) //aabbe
}

**********************************
aabbccdd	: 
aabbccdde	: e
aabbeccdd	: edcba
aabbccdd	: 
aabbccdde	: aabbccdde
aabbeccdd	: aabbe
```

---------------------

### iota

`iota`是`Golang`语言的常量计数器，只能在常量的`const`表达式中使用，在`const`关键字出现的时将被重置为`0`，`const`中每新增一行常量声明`iota`值**自增'1'**（`iota`可以理解为`const`语句块中的行索引）。

`iota`只能在常量的表达式中使用`，iota`在`const`关键字出现时将被重置为`0`，不同`const`定义块互不干扰。

```go
const a = iota // a = 0 => iota = 0, a = iota
const ( 
  b = iota     // b = 0 => iota = 0, b = iota
  c            // c = 1 => iota ++, c = iota
  d			   // d = 2 => iota ++, d = iota
)
```

### fallthrough

`Go`里面`switch`默认相当于每个`case`最后带有`break`，匹配成功后不会自动向下执行其他`case`，而是跳出整个`switch`, 但是可以使用`fallthrough`**强制**执行后面的**`case`**代码。

### [append()](https://juejin.cn/post/6951672096699187207)

- `append()`用来将元素添加到**切片末尾**并返回结果。
- 调用`append()`函数必须用**原来的切片变量**接收返回值
- `append()`追加元素，如果`slice`还有**容量**的话，就会将新的元素放在原来`slice`后面的剩余空间里，当底层数组装不下的时候，`Go`就会创建新的底层数组来保存这个切片，`slice`地址也随之改变。
- 分配了新的地址后，再把原来`slice`中的元素**逐个拷贝**到新的`slice`中，并返回。

```go
package  main
import "fmt"
//切片进阶操作
 
func main(){
	//append()为切片追加元素
	s1 := []string {"火鸡面","辛拉面","汤达人"}
	fmt.Printf("s1=%v len(s1)=%d cap(s1)=%d\n",s1,len(s1),cap(s1))
	
	//调用append函数必须用原来的切片变量接收返回值
	s1 = append(s1,"小当家") //append动态追加元素，原来的底层数组容纳不下足够多的元素时，切片就会开始扩容，Go底层数组就会把底层数组换一个
	fmt.Printf("s1=%v len(s1)=%d cap(s1)=%d\n",s1,len(s1),cap(s1))

	//调用append添加一个切片
	s2 := []string{"脆司令","圣斗士"}
	s1 = append(s1,s2...)//...表示拆开切片，再添加
	fmt.Printf("s1=%v len(s1)=%d cap(s1)=%d",s1,len(s1),cap(s1))
}

/*
	s1=[火鸡面 辛拉面 汤达人] len(s1)=3 cap(s1)=3
	s1=[火鸡面 辛拉面 汤达人 小当家] len(s1)=4 cap(s1)=6
	s1=[火鸡面 辛拉面 汤达人 小当家 脆司令 圣斗士] len(s1)=6 cap(s1)=6
*/
```

### string 和 byte 的转换

```go
s1 := "hello"
b := []byte(s1) // string to []byte
s2 := string(b) // []byte to string
```

### Interface 用法

#### [匿名字段和内嵌结构体](https://github.com/unknwon/the-way-to-go_ZH_CN/blob/master/eBook/10.5.md)

当我们需要重写一个 “实现了某个接口的结构体” 的部分方法，而其它方法保持不变 的时候，就需要用到这种用法。

```go 
package main

import (
    "fmt"
)

type Interface interface {
    Less(i, j int) bool
    Swap(i, j int)
}

// Array 实现Interface接口
type Array []int

func (arr Array) Less(i, j int) bool {
    return arr[i] < arr[j]
}

func (arr Array) Swap(i, j int) {
    arr[i], arr[j] = arr[j], arr[i]
}

// 匿名接口(anonymous interface)
type reverse struct {
    Interface
}

// 重写(override)
func (r reverse) Less(i, j int) bool {
    return r.Interface.Less(j, i)
}

// 构造reverse Interface
func Reverse(data Interface) Interface {
    return &reverse{data}
}

func main() {
    arr := Array{1, 2, 3}
    rarr := Reverse(arr)
    fmt.Println(arr.Less(0,1))
    fmt.Println(rarr.Less(0,1))
}
```

### [引入其他文件的struct](https://www.cnblogs.com/f-ck-need-u/p/9887233.html)

struct的属性是否被导出，也遵循大小写的原则：首字母大写的被导出，首字母小写的不被导出。

### internal 包

### protobuf

```go
type NATSession struct {
    Vrf   int32    `protobuf:"varint,1,opt,name=vrf,proto3" json:"vrf,omitempty"`
}
```

在 Golang 中，结构体中的`int32`后面的`protobuf`标记是用于指定结构体字段在序列化和反序列化时的编码格式。这是由于该结构体可能用于Protocol Buffers（protobuf）的序列化和反序列化操作。

### omitempty

1. 没有 json 标记时默认字段名称大写则序列化时默认使用该字段名。
2. 没有 json 标记时默认字段名称小写则序列化不会包含在内。
3. 有 json 标记时没有 omitempty 标记，序列化时将使用配置的 json 名称（字段大写时）
4. 有 json 标记时有 omitempty 标记，序列化时将忽略有 omitempty 并且没有赋值的字段，当具有值时则显示。
5. 有 json 标记时但名称为-时，当该字段值为空，则序列化时将忽略。

当 struct 中的字段没有值时， `json.Marshal()` 序列化的时候不会忽略这些字段，而是默认输出字段的类型零值（例如`int`和`float`类型零值是 0，`string`类型零值是`""`，对象类型零值是 nil）。如果想要在序列序列化时忽略这些没有值的字段时，可以在对应字段添加`omitempty` tag。

```go
type User struct {
	Name  string   `json:"name"`
	Email string   `json:"email"`
	Hobby []string `json:"hobby"`
}

func omitemptyDemo() {
	u1 := User{
		Name: "左右逢源",
	}
	// struct -> json string
	b, err := json.Marshal(u1)
	if err != nil {
		fmt.Printf("json.Marshal failed, err:%v\n", err)
		return
	}
	fmt.Printf("str:%s\n", b)
}

/*
	str:{"name":"左右逢源","email":"","hobby":null}
*/
```

```go
// 在tag中添加omitempty忽略空值
// 注意这里 hobby,omitempty 合起来是json tag值，中间用英文逗号分隔
type User struct {
	Name  string   `json:"name"`
	Email string   `json:"email,omitempty"`
	Hobby []string `json:"hobby,omitempty"`
}

/*
	str:{"name":"左右逢源"} // 序列化结果中没有email和hobby字段
*/
```

### 简式的变量声明

#### 仅可以在函数内部使用

```go
package main
myvar := 1 //error
func main() {  
}
```

#### 重复声明变量

不能在一个单独的声明中重复声明一个变量，但在多变量声明中这是允许的，其中至少要有一个新的声明变量。
重复变量需要在相同的代码块内，否则将得到一个隐藏变量。

```go
package main
func main() {  
    one := 0
    one := 1 //error
}
```

```go
package main
func main() {  
    one := 0
    one, two := 1,2
    one,two = two,one
}
```

### 命名返回值

Go 的返回值可被命名，它们会被视作定义在函数顶部的变量。

没有参数的 `return` 语句返回已命名的返回值。也就是 `直接` 返回。

```go
package main

import "fmt"

func split(sum int) (x, y int) {
	x = sum / 3
	y = sum - x
	return
}

func main() {
	fmt.Println(split(9))
}

/*
	3 6	
*/
```

### for 循环

Go 只有一种循环结构：`for` 循环。

基本的 `for` 循环由三部分组成，它们用分号隔开：

- 初始化语句：在第一次迭代前执行
- 条件表达式：在每次迭代前求值
- 后置语句：在每次迭代的结尾执行

初始化语句和后置语句是可选的。

```go
func main() {
	sum := 1
	for ; sum < 1000; {
		sum += sum
	}
	fmt.Println(sum) // 1024
}
```

去掉分号，可以理解为 while 循环。

```go
func main() {
	sum := 1
	for sum < 1000 {
		sum += sum
	}
	fmt.Println(sum) // 1024
}
```

### if 语句

`if` 语句可以在条件表达式前执行一个简单的语句，该语句声明的变量作用域仅在 `if` 之内。

在 `if` 的简短语句中声明的变量同样可以在任何对应的 `else` 块中使用。

```go
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	} else {
		fmt.Printf("%g >= %g\n", v, lim)
	}
	// 这里开始就不能使用 v 了
	return lim
}
```

### switch 语句

没有条件的 switch 同 `switch true` 一样，此时相当于是`if-then-else`语句。

### defer 语句

defer 语句会将函数推迟到外层函数返回之后执行。

推迟的函数调用会被压入一个栈中。当外层函数返回时，被推迟的函数会按照后进先出的顺序调用。

```go
func main() {
	fmt.Println("counting")

	for i := 0; i < 3; i++ {
		defer fmt.Println(i)
		fmt.Println(i)
	}

	fmt.Println("done")
}
/*
	counting
    0
    1
    2
    done
    2
    1
    0
*/
```
