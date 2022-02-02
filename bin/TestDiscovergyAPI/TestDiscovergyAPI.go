package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"example.com/mypowermonitor/discovergy"
	"example.com/mypowermonitor/myoauth"
	"github.com/dghubble/oauth1"
)

type DiscovergyAPI struct {
	ClientName            string
	Filename              string
	BaseUrl               string
	ClientRegistrationUrl string
	ConsumerKey           string
	ConsumerSecret        string
	RequestTokenUrl       string
	Oauth_token1          string
	Oauth_token_secret1   string
	AuthorizeURL          string
	Oauth_verifier        string
}

type ClientRegResponse struct {
	ConsumerKey    string `json:"key"`
	ConsumerSecret string `json:"secret"`
	Owner          string `json:"owner"`
}

func (api *DiscovergyAPI) ClientRegistration() error {
	fmt.Println("Start ClientRegistration()")
	client := &http.Client{
		Timeout: time.Second * 10,
	}

	data := url.Values{}
	data.Set("client", api.ClientName)
	encodedData := data.Encode()
	fmt.Println(encodedData)

	urlPath := api.BaseUrl + api.ClientRegistrationUrl

	req, err := http.NewRequest("POST", urlPath, strings.NewReader(encodedData))
	if err != nil {
		return fmt.Errorf("got error %s", err.Error())
	}

	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Add("Content-Length", strconv.Itoa(len(data.Encode())))
	response, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("got error %s", err.Error())
	}
	defer response.Body.Close()
	fmt.Println(response.Status)

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return fmt.Errorf("got error %s", err.Error())
	}
	//bodyString := string(body)
	//fmt.Println(bodyString)
	//Expected output:
	//{"key":"89vjamphh2dgcrtkeksuh7pp58","secret":"840q1r2t27db35lqqriovls6lm","owner":"MyTestClient","attributes":{},"principal":null}

	var r1 = ClientRegResponse{}
	err = json.Unmarshal(body, &r1)

	if err != nil {
		fmt.Println(err)
		return fmt.Errorf("got error %s", err.Error())
	}

	api.ConsumerKey = r1.ConsumerKey
	api.ConsumerSecret = r1.ConsumerSecret
	api.SaveToFile()
	return nil
}

func (api *DiscovergyAPI) SaveToFile() error {
	filename := api.ClientName + ".json"
	prettyJSON, err := json.MarshalIndent(api, "", "    ")
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

func (api *DiscovergyAPI) ReadApiFromFile() error {
	filename := api.ClientName + ".json"
	fmt.Println("Read " + filename)
	bites, err := ioutil.ReadFile(filename)
	json.Unmarshal(bites, &api)
	if err != nil {
		log.Fatal(err)
	}

	return nil
}

func (api *DiscovergyAPI) GetRequestToken() error {
	method := "POST"
	auth := myoauth.OAuth1{
		ConsumerKey:    api.ConsumerKey,
		ConsumerSecret: api.ConsumerSecret,
	}
	fmt.Println("Start GetRequestToken()")
	authHeader := auth.BuildOAuth1Header(method, api.RequestTokenUrl, map[string]string{})
	fmt.Println(authHeader)
	req, _ := http.NewRequest(method, api.BaseUrl+api.RequestTokenUrl, nil)
	// The header comes from the postman app
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Accept", "text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2")
	req.Header.Set("Connection", "keep-alive")

	if res, err := http.DefaultClient.Do(req); err == nil {
		defer res.Body.Close()
		fmt.Println(res.Status)
		body, _ := ioutil.ReadAll(res.Body)
		bodyString := string(body)
		//Expected output:
		//oauth_token=7741e9e12cf14f16b8b66064be482a4c&oauth_token_secret=hdhd0244k9j7ao03&oauth_callback_confirmed=true
		fmt.Println(bodyString)
	}

	return nil
}

func main() {
	fmt.Println("Start TestDiscovergyAPI")

	disapi := DiscovergyAPI{
		ClientName:            "MyTestClient",
		BaseUrl:               "https://api.discovergy.com",
		ClientRegistrationUrl: "/public/v1/oauth1/consumer_token",
		RequestTokenUrl:       "/public/v1/oauth1/request_token",
		AuthorizeURL:          "https://api.discovergy.com/public/v1/oauth1/authorize",
	}
	_ = disapi.ReadApiFromFile()

	if len(disapi.ConsumerKey) == 0 || len(disapi.ConsumerSecret) == 0 {
		_ = disapi.ClientRegistration()
		_ = disapi.SaveToFile()
	}

	// hier geht die Schleife los
	config := oauth1.Config{
		ConsumerKey:    disapi.ConsumerKey,
		ConsumerSecret: disapi.ConsumerSecret,
		// Tumblr does not support oob, uses consumer registered callback
		CallbackURL: "",
		Endpoint:    discovergy.Endpoint,
	}
	//fmt.Printf("%+v\n", config)

	requestToken, requestSecret, err := config.RequestToken()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%s \n", "Obtain request token")
	fmt.Printf("%s - %s \n", requestToken, requestSecret)

	authorizationURL, err := config.AuthorizationURL(requestToken)
	if err != nil {
		fmt.Printf("authorizationURL Error: %s", err.Error())
	} else {
		fmt.Printf("%s \n", authorizationURL)
	}
	fmt.Printf("%s \n", authorizationURL)

	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	req, err := http.NewRequest(http.MethodGet, authorizationURL.String(), nil)
	//req.Close = true
	if err != nil {
		println(err)
	}

	req.ParseForm()

	resp, err := client.Do(req)

	if err != nil {
		println("TEST")
		log.Fatal("Failed:  ", err)
	}
	bodyBytes, _ := io.ReadAll(resp.Body)

	bodyString := string(bodyBytes)
	values := strings.Split(bodyString, "=")

	fmt.Printf("Key: %s -- Value: %s \n", values[0], values[1])
	if values[0] == "oauth_verifie" {
		disapi.Oauth_verifier = values[1]
	}
	//	for key, value := range req.Form {
	//		fmt.Printf("%s == %s\n", key, value)
	//	}
	// handle err
	//w http.ResponseWriter
	//req *http.Request

	//http.Redirect(w, req, authorizationURL.String(), http.StatusFound)
	//u := discovergy.GetAuthorizeURL(endp.AuthorizeURL, "christian@familie-blank.de", "100Pas@Viv100")

	//fmt.Printf("%+v\n", u)
	//config := oauth1.NewConfig(disapi.ConsumerKey, disapi.ConsumerSecret)
	//fmt.Printf(">>>>>>>%+v", config)
	//_ = disapi.GetRequestToken()

	fmt.Printf("%+v\n\n", disapi)

}
