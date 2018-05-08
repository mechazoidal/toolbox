import argparse
import logging

from bs4 import BeautifulSoup
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry


class Pinboard(object):
    def __init__(self, user, api_key):
        self.logger = logging.getLogger(__name__)
        self.session = requests.Session()
        # https://stackoverflow.com/questions/23267409/how-to-implement-retry-mechanism-into-python-requests-library
        # pinboard correctly uses code 429,
        # so this implements an increasing backoff for 5 tries
        # with 1s, 2s, 4s, 8s, 16s
        retries = Retry(total=5, backoff_factor=1)
        self.session.mount('http://', HTTPAdapter(max_retries=retries))
        self.session.mount('https://', HTTPAdapter(max_retries=retries))
        self.user = user
        self.api_key = api_key
        self.base_url = "https://api.pinboard.in/v1/posts/{pb_method}"
        self.logger.debug(self)

    def post_operation(self, pb_method, url):
        pb_url = self.base_url.format(pb_method=pb_method)
        payload = {"auth_token": "{}:{}".format(
            self.user, self.api_key),
            "url": url}
        self.logger.debug("{} {}".format(pb_url, payload))
        # note that 'delete' and 'modify' are not kosher REST,
        # but pinboard owner don't care
        return self.session.get(pb_url, params=payload)

    def post_get(self, url):
        r = self.post_operation('get', url)
        if r.ok:
            r_soup = BeautifulSoup(r.content, "xml")
            if r_soup.post and r_soup.post.attrs['href'] == url:
                return {"description": r_soup.post.attrs['description'],
                        "href": r_soup.post.attrs['href'],
                        "tags": r_soup.post.attrs['tag'].split(' ')
                        }
        else:
            return {"href": url,
                    "status_code": r.status_code,
                    "reason": r.reason}

    def post_delete(self, url):
        r = self.post_operation('delete', url)
        if r.ok:
            r_soup = BeautifulSoup(r.content, "xml")
            self.logger.debug(r_soup)
            if r_soup.result:
                return {"href": url, "result": r_soup.result['code']}
        else:
            return {"href": url,
                    "status_code": r.status_code,
                    "reason": r.reason}

    def post_add(self, url, description, tags=[]):
        if not self.post_get(url):
            pb_url = self.base_url.format(method="add")
            payload = {"auth_token": "{}:{}".format(
                self.user, self.api_key),
                "url": url,
                "description": description,
                "tags": tags,
                "replace": "no"}
            # Yes, this is not kosher REST, but pinboard owner don't care
            self.logger.debug("{} {}".format(pb_url, payload))
            r = self.session.get(pb_url, params=payload)
            if r.ok:
                return True
            else:
                return {"status_code": r.status_code, "reason": r.reason}


def main():
    parser = argparse.ArgumentParser(description="manipulate pinboard api")
    parser.add_argument('-u', "--user")
    parser.add_argument('-t', "--token")
    parser.add_argument('-v', "--verbose", action="store_true")

    parser.add_argument('action', choices=['get', 'delete'])
    parser.add_argument('urls', nargs="+", help="List of urls")

    args = parser.parse_args()
    pb = Pinboard(user=args.user, api_key=args.token)
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    pb.logger.debug(args)
    method = getattr(pb, "post_{}".format(args.action))
    url_objs = [method(item) for item in args.urls]
    print(url_objs)


if __name__ == '__main__':
    main()
