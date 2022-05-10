package discovergy

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

	"github.com/dghubble/oauth1"
)

var Endpoint = oauth1.Endpoint{}

func (api *DiscovergyAPI) ClientRegistration() error {
	loggerConfig.ZapLogger.Info("Start ClientRegistration()")
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+ https://api.discovergy.com/docs/#/OAuth1/getConsumerCredentials
	//+	Discovergy /oauth1/consumer_token Authorization Step 1
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	client := &http.Client{
		Timeout: time.Second * 20,
	}

	data := url.Values{}
	data.Set("client", api.Config.ClientName)
	encodedData := data.Encode()
	//fmt.Println(encodedData)
	loggerConfig.ZapLogger.Debug(encodedData)
	urlPath := api.Config.BaseUrl + api.Config.ClientRegistrationUrl

	req, err := http.NewRequest("POST", urlPath, strings.NewReader(encodedData))
	if err != nil {
		return err
	}

	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Add("Content-Length", strconv.Itoa(len(data.Encode())))
	response, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("got error %s", err.Error())
	}
	defer response.Body.Close()

	loggerConfig.ZapLogger.Debug(response.Status)
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return err
	}

	var r1 = ClientRegResponse{}
	err = json.Unmarshal(body, &r1)

	if err != nil {
		return err
	}

	api.Config.ConsumerKey = r1.ConsumerKey
	api.Config.ConsumerSecret = r1.ConsumerSecret
	_ = api.SaveToFile()
	return nil
}

func (api *DiscovergyAPI) config_oauth1() (oauth1.Config, error) {
	Endpoint.RequestTokenURL = api.Config.BaseUrl + api.Config.RequestTokenUrl
	Endpoint.AuthorizeURL, _ = GetAuthorizeURL(api.Config.BaseUrl + api.Config.AuthorizeURL)
	Endpoint.AccessTokenURL = api.Config.BaseUrl + api.Config.AccessTokenURL

	config := oauth1.Config{
		ConsumerKey:    api.Config.ConsumerKey,
		ConsumerSecret: api.Config.ConsumerSecret,
		CallbackURL:    "",
		Endpoint:       Endpoint,
	}

	return config, nil
}

func (api *DiscovergyAPI) NewToken() error {

	oauth1, _ := api.config_oauth1()

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+ https://api.discovergy.com/docs/#/OAuth1/getConsumerCredentials
	//+	Discovergy /oauth1/request_token Authorization Step 2
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	requestToken, requestSecret, err := oauth1.RequestToken()
	if err != nil {
		log.Fatal(err)
	}

	api.Oauth_RequestToken = requestToken
	api.Oauth_RequestSecret = requestSecret

	loggerConfig.ZapLogger.Debugf("%s", "Obtain request token")

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+ https://api.discovergy.com/docs/#/OAuth1/getConsumerCredentials
	//+	Discovergy /oauth1/authorize Authorization Step 3
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	authorizationURL, err := oauth1.AuthorizationURL(requestToken)
	if err != nil {
		loggerConfig.ZapLogger.Errorf("authorizationURL: %s", authorizationURL)
		loggerConfig.ZapLogger.Errorf("authorizationURL Error: %s", err.Error())
	}

	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	req, err := http.NewRequest(http.MethodGet, authorizationURL.String(), nil)

	if err != nil {
		loggerConfig.ZapLogger.Error(err)
	}

	req.ParseForm()

	resp, err := client.Do(req)

	if err != nil {
		loggerConfig.ZapLogger.Fatal("Failed:  ", err)
	}
	bodyBytes, _ := io.ReadAll(resp.Body)

	bodyString := string(bodyBytes)
	values := strings.Split(bodyString, "=")

	if values[0] == "oauth_verifier" {
		api.Oauth_Verifier = values[1]
	}
	loggerConfig.ZapLogger.Debugf("%s", "Obtain verifier")

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+ https://api.discovergy.com/docs/#/OAuth1/getConsumerCredentials
	//+	Discovergy /oauth1/access_token Authorisation Step 4
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	accessToken, accessSecret, err := oauth1.AccessToken(requestToken, requestSecret, api.Oauth_Verifier)

	if err != nil {
		loggerConfig.ZapLogger.Error("Error: oauth1.AccessToken ")
		loggerConfig.ZapLogger.Fatal("Failed:  ", err)
	}

	api.Oauth_AccessToken = accessToken
	api.Oauth_AccessSecret = accessSecret
	loggerConfig.ZapLogger.Debugf("%s", "Obtain AccessToken")
	_ = api.SaveToFile()
	return nil
}
