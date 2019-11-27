package main

import (
	"bytes"
	"fmt"
	cli "github.com/urfave/cli/v2"
	"io"
	"log"
  "crypto/tls"
	"mime/multipart"
	"net/http"
  "time"
	"os"
	"path/filepath"
)

// Creates a new file upload http request with optional extra params
func newfileUploadRequest(uri string, paramName, path string) (*http.Request, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)
	part, err := writer.CreateFormFile(paramName, filepath.Base(path))
	if err != nil {
		return nil, err
	}
	_, err = io.Copy(part, file)

	err = writer.Close()
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("PUT", uri, body)
	req.Header.Set("Content-Type", writer.FormDataContentType())
	return req, err
}

func upload_blob(serverURL string, useHTTP2 bool, file string) {
	request, err := newfileUploadRequest(serverURL, "file", file)

	if err != nil {
		log.Fatal(err)
	}

  tr := &http.Transport{}

  if(!useHTTP2) {
    fmt.Println("Using http1.1")
    tr.TLSNextProto = map[string]func(string, *tls.Conn) http.RoundTripper{}
  } else {
    fmt.Println("Using http2")
  }

	client := &http.Client{
		Transport: tr,
	}

  startTime := time.Now()
  fmt.Println("Started at", startTime.Format("2006-01-02 15:04:05.000000"))
	resp, err := client.Do(request)
	if err != nil {
		log.Fatal(err)
	} else {
		body := &bytes.Buffer{}
		_, err := body.ReadFrom(resp.Body)
		if err != nil {
			log.Fatal(err)
		}
		resp.Body.Close()
	}
  endTime := time.Now()
  fmt.Println("Ended at", endTime.Format("2006-01-02 15:04:05.000000"))
  duration := endTime.Sub(startTime)
  fmt.Println("Upload took", time.Time{}.Add(duration).Format("15:04:05"))
}

func main() {
	app := &cli.App{
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:  "target",
				Value: "english",
				Usage: "upload FILE to this url",
			},
			&cli.BoolFlag{
				Name:  "http2",
				Usage: "use http2 for connection",
			},
			&cli.StringFlag{
				Name:     "file",
				Usage:    "the file to upload",
				Required: true,
			},
		},
		Action: func(c *cli.Context) error {
			upload_blob(c.String("target"), c.Bool("http2"), c.String("file"))
			return nil
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}

}
