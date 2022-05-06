package discovergy

/*
	Requires the following variables
	On Powershell:
	*  $Env:ClientName = "discovergy_ws"
	Discovergy Account:
	*  $Env:DiscovergyEmail = "fffffffff@mail.de"
	*  $Env:DiscovergyPasswd = "********"
	Bash use export
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
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"

	"example.com/mypowermonitor/myoauth"
	"example.com/mypowermonitor/power_util"
)

var loggerConfig *power_util.LoggerConfig

func (api *DiscovergyAPI) Set_LoggerConfig(p_logger *power_util.LoggerConfig) {
	loggerConfig = p_logger
}

func (api *DiscovergyAPI) CheckOsEnv() error {
	//Read enviroment variable "ClientName"
	api.Config.ClientName = os.Getenv("ClientName")

	if len(api.Config.ClientName) == 0 {
		panic("Not set the Env Variable ClientName")
	}

	if os.Getenv("DiscovergyEmail") == "" || os.Getenv("DiscovergyPasswd") == "" {
		panic("Not set the Env Variable DiscovergyEmail or DiscovergyPasswd for the Discovergy Account")
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
	loggerConfig.ZapLogger.Infof("Read %s", filename)
	//fmt.Println("Read " + filename)
	bites, err := ioutil.ReadFile(filename)
	json.Unmarshal(bites, &api.Config)
	if err != nil {
		log.Fatal(err)
	}

	return nil
}

func (api *DiscovergyAPI) SaveToFile() error {
	filename := "config_" + api.Config.ClientName + ".json"
	loggerConfig.ZapLogger.Debugf("Save File %s", filename)

	api.Config.Filename = filename
	prettyJSON, err := json.MarshalIndent(api.Config, "", "    ")
	if err != nil {
		loggerConfig.ZapLogger.Fatal("Failed to generate json", err)
	}

	toWrite := []byte(prettyJSON)
	err = ioutil.WriteFile(filename, toWrite, 0644)
	if err != nil {
		loggerConfig.ZapLogger.Fatal("Failed to generate json", err)
	}
	return nil
}

func (api *DiscovergyAPI) GetLastRead() (string, int, error) {
	var auth myoauth.OAuth1
	local_conf := api.Config

	auth.ConsumerKey = local_conf.ConsumerKey
	auth.ConsumerSecret = local_conf.ConsumerSecret
	auth.AccessToken = api.Oauth_AccessToken
	auth.AccessSecret = api.Oauth_AccessSecret
	method := http.MethodGet
	last_readurl := local_conf.BaseUrl + local_conf.LastReadUrl
	// Methode + Baseurl + Parameter need for the signing string ( show myoauth signatureBase)
	authHeader := auth.BuildOAuth1Header(method, last_readurl, map[string]string{
		"meterId": local_conf.MeterId,
		"fields":  local_conf.ReadingFealds,
	})

	req, _ := http.NewRequest(method, last_readurl, nil)
	// The header comes from the postman app
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Connection", "keep-alive")

	// Build the complete url
	q := url.Values{}
	q.Add("meterId", local_conf.MeterId)
	q.Add("fields", local_conf.ReadingFealds)
	req.URL.RawQuery = q.Encode()

	// Now the actual http get request
	if res, err := http.DefaultClient.Do(req); err == nil {
		defer res.Body.Close()
		resStatusCode := res.StatusCode
		//fmt.Printf("%s - %s\n", power_util.GetTimeStr(), res.Status)
		body, _ := ioutil.ReadAll(res.Body)
		bodyString := string(body)
		//Expected output:
		//{"time":1636152869126,"values":{"energyOut":119411587467000,"energy":138376348839000,"power":344460}}
		//fmt.Println(bodyString)
		return bodyString, resStatusCode, nil
	} else {
		resStatusCode := res.StatusCode
		return "ERROR", resStatusCode, err
	}

}
