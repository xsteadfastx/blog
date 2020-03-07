package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"regexp"
)

func main() {
	dir := flag.String("dir", "", "directory.")
	flag.Parse()
	files, err := ioutil.ReadDir(*dir)
	if err != nil {
		log.Fatal(err)
	}
	articles := make([]string, 0)
	for _, i := range files {
		abs, err := filepath.Abs(filepath.Join(*dir, i.Name()))
		if err != nil {
			log.Fatal(err)
		}
		articles = append(articles, abs)
	}
	for _, a := range articles {
		go func(a string) {
			data, err := ioutil.ReadFile(a)
			if err != nil {
				log.Fatal(err)
			}
			reIframe := regexp.MustCompile(`(?U)(<iframe\s.+>)`)
			for _, m := range reIframe.FindAllStringSubmatch(string(data), -1) {
				fmt.Print(m)
			}
		}(a)
	}
}
