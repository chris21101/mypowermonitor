package discovergy

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

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/url"
	"os"
)

func (api *DiscovergyAPI) CheckOsEnv() error {
	//Read enviroment variable "ClientName"
	api.Config.ClientName = os.Getenv("ClientName")

	if len(api.Config.ClientName) == 0 {
		panic("Not set the Env Variable ClientName")
	}

	if os.Getenv("DiscovergyEmail") == "" || os.Getenv("DiscovergyPasswd") == "" {
		panic("Not set the Env Variable DiscovergyEmail or DiscovergyPasswd")
	}
	return nil
}

func GetAuthorizeURL(authUrl string) (string, error) {
	u, err := url.Parse(authUrl)
	if err != nil {
		log.Fatal(err)
	}
	values := u.Query()
	values.Set("email", os.Getenv("DiscovergyEmail"))
	values.Set("password", os.Getenv("DiscovergyPasswd"))

	u.RawQuery = values.Encode()

	return u.String(), nil
}

func (api *DiscovergyAPI) ReadConfigFromFile() error {
	filename := "config_" + api.Config.ClientName + ".json"
	api.Config.Filename = filename
	fmt.Println("Read " + filename)
	bites, err := ioutil.ReadFile(filename)
	json.Unmarshal(bites, &api.Config)
	if err != nil {
		log.Fatal(err)
	}

	return nil
}

func (api *DiscovergyAPI) SaveToFile() error {
	filename := "config_" + api.Config.ClientName + ".json"

	fmt.Println("Save File " + filename)

	api.Config.Filename = filename
	prettyJSON, err := json.MarshalIndent(api.Config, "", "    ")
	if err != nil {
		log.Fatal("Failed to generate json", err)
	}

	toWrite := []byte(prettyJSON)
	err = ioutil.WriteFile(filename, toWrite, 0644)
	if err != nil {
		log.Fatal("Failed to generate json", err)
	}
	return nil
}
