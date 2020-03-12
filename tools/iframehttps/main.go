package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"regexp"
	"sync"
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
	var wg sync.WaitGroup
	for _, a := range articles {
		wg.Add(1)
		go func(a string, wg *sync.WaitGroup) {
			defer wg.Done()
			data, err := ioutil.ReadFile(a)
			if err != nil {
				log.Fatal(err)
			}
			reIframe := regexp.MustCompile(`(?U)(<iframe\s.+>)`)
			for _, m := range reIframe.FindAllString(string(data), -1) {
				reSrc := regexp.MustCompile(`(?U)src="http://(.+)"`)
				for _, s := range reSrc.FindAllStringSubmatch(m, -1) {
					httpsUrl := fmt.Sprintf("https://%s\n", s[1])
					log.Printf("%s => %s", fmt.Sprintf("http://%s", s[1]), httpsUrl)
					data = reSrc.ReplaceAll(data, []byte(`src="https://$1"`))
				}
			}
			if err := ioutil.WriteFile(a, []byte(data), 0644); err != nil {
				log.Fatal(err)
			}
		}(a, &wg)
	}

	wg.Wait()
}
