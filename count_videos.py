import os
import requests
import warnings
from urllib3.exceptions import InsecureRequestWarning
from google.oauth2 import service_account
import google.auth.transport.requests

warnings.simplefilter('ignore', InsecureRequestWarning)
old_request = requests.Session.request
def new_request(*args, **kwargs):
    kwargs['verify'] = False
    return old_request(*args, **kwargs)
requests.Session.request = new_request

FIREBASE_KEY_PATH = r'C:\Users\Azhar Arshad\Downloads\mobile-app-f270c-firebase-adminsdk-fbsvc-774118213a.json'
PROJECT_ID = 'mobile-app-f270c'

credentials = service_account.Credentials.from_service_account_file(
    FIREBASE_KEY_PATH, 
    scopes=['https://www.googleapis.com/auth/datastore']
)
auth_req = google.auth.transport.requests.Request()
credentials.refresh(auth_req)

url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/videos"

documents = []
next_page_token = ""

while True:
    req_url = url + "?pageSize=300"
    if next_page_token:
        req_url += f"&pageToken={next_page_token}"
        
    res = requests.get(req_url, headers={"Authorization": f"Bearer {credentials.token}"}, verify=False).json()
    
    docs = res.get('documents', [])
    documents.extend(docs)
    
    next_page_token = res.get('nextPageToken', None)
    if not next_page_token:
        break

print(f"TOTAL_VIDEOS: {len(documents)}")
