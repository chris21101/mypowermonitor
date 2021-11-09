package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"

	"example.com/mypowermonitor/myoauth"
)

func main() {
	//All needed for the last_reading method from api.discovergy.com
	method := http.MethodGet
	baseurl := "https://api.discovergy.com/public/v1/last_reading"
	//Parameters
	meterId := "345598f062f64a5196b556d5d2a50746"
	fields := "energy,energyOut,power"

	// Genereated with postman collection 02-Discovergy
	auth := myoauth.OAuth1{
		ConsumerKey:    "cksuirhcnrfr2ti43pvi4aq641",
		ConsumerSecret: "d759m7nvomdl22r46c13hpb1a",
		AccessToken:    "1d9f3ac0bc8c4ca198a10fede98199b4",
		AccessSecret:   "c6d6383a75744d1fb45054806f15f41f",
	}

	// Methode + Baseurl + Parameter need for the signing string ( show myoauth signatureBase)
	authHeader := auth.BuildOAuth1Header(method, baseurl, map[string]string{
		"meterId": meterId,
		"fields":  fields,
	})

	req, _ := http.NewRequest(method, baseurl, nil)
	// The header comes from the postman app
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Connection", "keep-alive")

	// Build the complete url
	q := url.Values{}
	q.Add("meterId", meterId)
	q.Add("fields", fields)
	req.URL.RawQuery = q.Encode()

	// Now the actual http get request
	if res, err := http.DefaultClient.Do(req); err == nil {
		defer res.Body.Close()
		fmt.Println(res.Status)
		body, _ := ioutil.ReadAll(res.Body)
		bodyString := string(body)
		//Expected output:
		//{"time":1636152869126,"values":{"energyOut":119411587467000,"energy":138376348839000,"power":344460}}
		fmt.Println(bodyString)
	}

}
