package discovergy

import (
	"log"
	"net/url"

	"github.com/dghubble/oauth1"
)

// Endpoint is Tumblr's OAuth 1a endpoint.
var Endpoint = oauth1.Endpoint{
	RequestTokenURL: "https://api.discovergy.com/public/v1/oauth1/request_token",
	AuthorizeURL:    "https://api.discovergy.com/public/v1/oauth1/authorize?email=christian@familie-blank.de&password=100Pas@Viv100",
	AccessTokenURL:  "https://api.discovergy.com/public/v1/oauth1/access_token",
}

func GetAuthorizeURL(authUrl string, email string, passwd string) string {
	u, err := url.Parse(authUrl)
	if err != nil {
		log.Fatal(err)
	}
	values := u.Query()
	values.Set("email", email)
	values.Set("password", passwd)

	u.RawQuery = values.Encode()

	//fmt.Println(u.String())
	//	u.Opaque = "opaque"
	//	fmt.Println(u.String())
	return u.String()
}
