package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"net/http"
	"net/http/httputil"
	"strings"
)

func handler(req events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	// Extract payload from GitHub webhook
	payload := req.Body
	path := strings.Replace(req.RawPath, "/staging", "", 1)

	// Set the URL of your private ALB
	albURL := "https://staging.domain.com" + path
	fmt.Println(albURL)

	client := http.Client{}
	redirectReq, err := http.NewRequest("POST", albURL, strings.NewReader(payload))
	if err != nil {
		return events.APIGatewayV2HTTPResponse{}, err
	}

	for key, value := range req.Headers {
		redirectReq.Header.Set(key, value)
	}
	resp, err := client.Do(redirectReq)

	if err != nil {
		return events.APIGatewayV2HTTPResponse{}, err
	}
	defer resp.Body.Close()

	responseBody := fmt.Sprintf("Redirected to private ALB. Status: %s", resp.Status)
	b, err := httputil.DumpResponse(resp, true)
	if err != nil {
		fmt.Printf("error on parse body")
	}

	fmt.Println(string(b))

	return events.APIGatewayV2HTTPResponse{
		StatusCode: resp.StatusCode,
		Headers:    map[string]string{"Content-Type": "text/plain"},
		Body:       responseBody,
	}, nil
}

func main() {
	lambda.Start(handler)
}
