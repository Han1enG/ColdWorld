+++
title = '解析 Yaml 文件失败使用默认值替换失败字段'
date = 2024-02-28T22:52:10+08:00
tags = ["Golang", "Yaml"]
categories = ["Technology"]
+++

### 场景

当 Yaml 作为配置文件时候，往往在启动服务的时候就需要解析配置，如果修改了某个字段的数据结构，开局就 panic，有时候我们并不希望此时就停止业务，希望能用默认的配置文件替代。

```yaml
# cfg.yaml
language: Golang
animal: Dog
```

```go
type Cfg struct {
	Language    string `json:"language,omitempty"`
	Animal 		string `json:"animal,omitempty"`
}
```

正常情况下，Yaml 文件会被解析成功，如下：

```go
package main

import (
	"fmt"
	"os"

	"github.com/goccy/go-yaml"
)

type Cfg struct {
	Language string `json:"language,omitempty"`
	Animal   string `json:"animal,omitempty"`
}

func main() {
	CfgPath := "C:\\Users\\han1en9\\Desktop\\Project\\Demo\\cfg.yaml"

	var cfg Cfg
	b, _ := os.ReadFile(CfgPath)

	if err := yaml.Unmarshal(b, &cfg); err != nil {
		fmt.Printf("解析配置失败, err : %v", err)
	}
	fmt.Println(cfg)
}
// {Golang Dog}
```

当我们修改 Yaml 文件时，如修改 language 字段为数组：

```yaml
# cfg.yaml
language:
  - Golang
animal: Dog
```

报错信息如下：

> 解析配置失败, err : [4:3] cannot unmarshal []interface {} into Go struct field Cfg.Language of type string
> 1 | # cfg.yaml
> 2 | language:
> 3 | - Golang
> ^
> { Dog} 5 | animal: Dog

此时我们希望解析错误的字段用默认值代替，很多 unmarshal 函数在解析出错的第一个字段后就返回错误，剩余字段不再去解析，想了一个曲线救国的方法，希望大家有更好的建议。

```go
func main() {
	CfgPath := "C:\\Users\\han1en9\\Desktop\\Project\\Demo\\cfg.yaml"

	var cfg Cfg
	b, _ := os.ReadFile(CfgPath)

	if err := yaml.Unmarshal(b, &cfg); err != nil {
		defaultSettings := map[string]interface{}{
			"language": "Golang",
			"animal":   "Dog",
		}
		tmpCfg := make(map[string]interface{})
		if err = yaml.Unmarshal(b, &tmpCfg); err != nil {
			fmt.Printf("解析配置失败, err : %v", err)
			return
		}
		// 应用默认设置到解析失败的字段
		for key, value := range defaultSettings {
			// 添加缺失的字段并使用默认值并检查解析字段的类型和默认设置的类型是否一致
			if fieldValue, ok := tmpCfg[key]; !ok || reflect.TypeOf(fieldValue) != reflect.TypeOf(value) {
				tmpCfg[key] = value
			}
		}
		// 将解析结果转换为 Cfg 结构
		cfg = Cfg{
			Language: tmpCfg["language"].(string),
			Animal:   tmpCfg["animal"].(string),
		}
	}
	fmt.Println(cfg)
}
// {Golang Dog}
```
