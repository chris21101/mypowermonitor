package oracleRestClient

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
	"time"

	"example.com/mypowermonitor/power_util"
)

type OracleRestJsonRequest struct {
	Aouthurl      string
	ClientID      string
	ClientSecret  string
	AccessUrl     string
	Oauthtoken    string
	Status        string
	StatusCode    int
	Error_message string
	Body          []byte
}

type OracleTokenRequest struct {
	Aouthurl     string `json:"aouthurl"`
	ClientID     string `json:"client_id"`
	ClientSecret string `json:"client_secret"`
}

var loggerConfig *power_util.LoggerConfig

func (r *OracleRestJsonRequest) Set_LoggerConfig(p_logger *power_util.LoggerConfig) {
	loggerConfig = p_logger
}

func (r *OracleRestJsonRequest) GetOracleDBtoken(tr OracleTokenRequest) (string, error) {
	// Generated by curl-to-Go: https://mholt.github.io/curl-to-go

	// curl
	// --user K04P-iGbYvqLWrGeJMy_Qg..:UUXE71CDaj3mf0c3KBsltw..
	// --data 'grant_type=client_credentials'
	// https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/hr/oauth/token
	//

	type Oauthresponse struct {
		Access_token string `json:"access_token"`
		Token_type   string `json:"token_type"`
		Expires_in   int32  `json:"expires_in"`
	}

	r1 := Oauthresponse{}

	params := url.Values{}
	params.Add("grant_type", `client_credentials`)
	body := strings.NewReader(params.Encode())

	req, err := http.NewRequest("POST", tr.Aouthurl, body)

	if err != nil {
		return "", err
	}
	req.SetBasicAuth(tr.ClientID, tr.ClientSecret)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		loggerConfig.ZapLogger.Errorf("++++++++++++++++++++ ERROR Do Req: %s", err)
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		//statusCode := resp.StatusCode
		r.Status = resp.Status
		r.StatusCode = resp.StatusCode
		err := errors.New("ERROR: GetOracleDBtoken")
		return "", fmt.Errorf("%v : %s", err, resp.Status)
	}
	bodyR, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		return "", err
	}

	err = json.Unmarshal(bodyR, &r1)
	if err != nil {
		return "", err
	}
	return "Bearer " + r1.Access_token, nil
}

func (r *OracleRestJsonRequest) SaveJsonOracleDB(jstring string) error {
	newTokenRequest := OracleTokenRequest{
		Aouthurl:     r.Aouthurl,
		ClientID:     r.ClientID,
		ClientSecret: r.ClientSecret,
	}

	if r.Oauthtoken == "" {
		newtoken, err := r.GetOracleDBtoken(newTokenRequest)
		if err != nil {
			return fmt.Errorf("GetOracleDBtoken: %v", err)
		}

		r.Oauthtoken = newtoken
		loggerConfig.ZapLogger.Infof("Get New Oracle TOKEN:%s", r.Oauthtoken)
	}
	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	req, err := http.NewRequest(http.MethodPost, r.AccessUrl, bytes.NewBuffer([]byte(jstring)))

	if err != nil {
		return fmt.Errorf("SaveJsonOracleDB - new oracle post request: %v", err)
	}
	req.Close = true
	req.Header.Set("Authorization", r.Oauthtoken)
	req.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(req)
	if err != nil {
		defer resp.Body.Close()
		return fmt.Errorf("SaveJsonOracleDB - client.Do(req): %v http_status: %s", err, resp.Status)
	}

	defer resp.Body.Close()

	r.Status = resp.Status
	r.StatusCode = resp.StatusCode
	r.Error_message = resp.Header.Get("ERROR_MESSAGE")
	//fmt.Printf("%v\n", r)
	body, _ := ioutil.ReadAll(resp.Body)

	if err != nil {
		r.Body = body
		return fmt.Errorf("SaveJsonOracleDB - post respond: %v http_status: %s Error: %s ", err, r.Status, r.Error_message)
	}
	if resp.StatusCode == 401 {
		//We need a new token now
		newtoken, err := r.GetOracleDBtoken(newTokenRequest)
		if err != nil {
			return err
		}
		r.Oauthtoken = newtoken
	}
	//fmt.Printf("SaveJsonOracleDB - http status != 200: %v http_status: %s Error: %s ", err, r.Status, r.Error_message)
	if resp.StatusCode != 202 {
		return fmt.Errorf("SaveJsonOracleDB - http_status: %d Error: %s ", r.StatusCode, r.Status)
	}
	return nil
}
