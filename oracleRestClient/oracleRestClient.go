package oracleRestClient

type OracleTokenRequest struct {
	Aouthurl     string `json:"aouthurl"`
	ClientID     string `json:"client_id"`
	ClientSecret string `json:"client_secret"`
}

type OraclePostRequest struct {
	accessUrl  string
	oauthtoken string
}
