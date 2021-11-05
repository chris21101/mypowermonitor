package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"

	"example.com/kostalinverter/myoauth"
)

func main() {
	method := http.MethodGet
	baseurl := "https://api.discovergy.com/public/v1/last_reading"
	meterId := "345598f062f64a5196b556d5d2a50746"
	fields := "energy,energyOut,power"

	auth := myoauth.OAuth1{
		ConsumerKey:    "k0klr0gi2676vrqnq0tgbikns8",
		ConsumerSecret: "ou51lpns3q1985gpmbnjqb8qll",
		AccessToken:    "86dcc4990f72403e8ba269a70eac2cc8",
		AccessSecret:   "8c9cdf9e8c8f495a8d5c6fd217bd7185",
	}

	// Methode + Baseurl + Parameter need for the signing string ( show myoauth signatureBase)
	authHeader := auth.BuildOAuth1Header(method, baseurl, map[string]string{
		"meterId": meterId,
		"fields":  fields,
	})

	req, _ := http.NewRequest(method, baseurl, nil)

	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Connection", "keep-alive")

	//build the complete url
	q := url.Values{}
	q.Add("meterId", meterId)
	q.Add("fields", fields)
	req.URL.RawQuery = q.Encode()

	if res, err := http.DefaultClient.Do(req); err == nil {
		defer res.Body.Close()
		fmt.Println(res.Status)
		body, _ := ioutil.ReadAll(res.Body)
		bodyString := string(body)
		fmt.Println(bodyString)
	}

}
