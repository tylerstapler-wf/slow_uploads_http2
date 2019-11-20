#!/usr/bin/env python3
import requests
import datetime
# Hyper adds support for http2 to python's requestssts library
from hyper.contrib import HTTP20Adapter
from requests_toolbelt import MultipartEncoder
# sslkeylog handles logging out the client pre-master secret
# so we can decrypt the traffic later.
#
# You can load this file into wireshark
import sslkeylog
sslkeylog.set_keylog("sslkeylog.txt")

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('--target',
                        default="http://127.0.0.1:8000/uploadfile/",
                        help="upload FILE to this url")
    parser.add_argument('--http2',
                        action='store_true',
                        help="use http2 for connection")
    parser.add_argument('--file', help="upload this file", required=True)

    args = parser.parse_args()
    s = requests.Session()
    if args.http2:
        print("Using http2")
        s.mount('https://', HTTP20Adapter())
    else:
        print("Using http1")

    with open(args.file, 'rb') as f:
        # MultipartEncoder allows us to do a streaming upload of a large file
        m = MultipartEncoder(fields={'file': ('filename', f, 'text/plain')})

        start = datetime.datetime.now()
        print(f"Started at {start}")
        s.put(args.target, data=m, headers={'Content-Type': m.content_type})
        end = datetime.datetime.now()
        print(f"Ended at { end }")
        duration = end - start
        print(f"Upload took: {duration}")
