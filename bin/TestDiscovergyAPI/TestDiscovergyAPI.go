package main

import (
	"fmt"
	"os"

	"example.com/mypowermonitor/discovergy"
)

func main() {
	fmt.Println("Start TestDiscovergyAPI")
	var disapi discovergy.DiscovergyAPI

	//Needs Env "ClientName, DiscovergyEmail and DiscovergyPasswd"
	_ = disapi.CheckOsEnv()

	/*
		Needs config file config_<ClientName>.json in the root directory
		https://api.discovergy.com/docs/#/OAuth1
		Example config_discovergy_ws.json
		{
		"ClientName": "discovergy_ws",
		"Filename": "config_discovergy_ws.json",
		"BaseUrl": "https://api.discovergy.com",
		"MeterId": "345598f062f64a5196b556d5d2a50746",
		"ReadingFealds": "energy,energyOut,power",
		"ClientRegistrationUrl": "/public/v1/oauth1/consumer_token",
		"RequestTokenUrl": "/public/v1/oauth1/request_token",
		"AuthorizeURL": "/public/v1/oauth1/authorize",
		"AccessTokenURL": "/public/v1/oauth1/access_token",
		"LastReadUrl": "/public/v1/last_reading",
		"ConsumerKey": "",
		"ConsumerSecret": ""
		}
	*/
	_ = disapi.ReadConfigFromFile()

	// Programm needs a ConsumerKey and ConsumerSecret
	if len(disapi.Config.ConsumerKey) == 0 || len(disapi.Config.ConsumerSecret) == 0 {
		err := disapi.ClientRegistration()

		if err != nil {
			fmt.Printf("Failed ClientRegistration: %s \n", err)
			os.Exit(3)
		}
	} else {
		fmt.Println("Client is registered")
	}

	// Every 24h we need a new token ???
	err := disapi.NewToken()
	if err != nil {
		fmt.Printf("Failed NewToken: %s \n", err)
		os.Exit(3)
	}

}
