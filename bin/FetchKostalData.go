package main

import (
	"fmt"
	"time"

	"example.com/kostalinverter/kostalinverter"
)

func main() {
	var j = 0
	for {
		jDate, err := kostalinverter.FetchKostalDates()
		if err != nil {
			fmt.Println(err)
		}

		j++
		fmt.Printf("%d : %s\n", j, jDate)
		time.Sleep(1 * time.Second)
	}
}
