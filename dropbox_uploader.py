import os
import requests
import warnings
import dropbox
import time
import uuid
from datetime import datetime
from urllib3.exceptions import InsecureRequestWarning
from google.oauth2 import service_account
import google.auth.transport.requests

# Bypass SSL verification on Windows
warnings.simplefilter('ignore', InsecureRequestWarning)
old_request = requests.Session.request
def new_request(*args, **kwargs):
    kwargs['verify'] = False
    return old_request(*args, **kwargs)
requests.Session.request = new_request

# =======================================================
# WATCH & EARN: DROPBOX TO FIREBASE UPLOADER (REST API)
# =======================================================

DROPBOX_ACCESS_TOKEN = 'sl.u.AGl0eagzlWdBLg6LJFuuHA75KX6uqXfp7sUzlJq4HrP54VAQRtT_rgmnBLGCuPFjha2RR9kNjyBsYB6btk89ZWmvyOEdumxN6H-dIEp9ZrFjIuIQ_9NYG7YYIaIXPWkX576TY6N03ztWEd2e7VPnFMAEuCaP6bd6iAEGDDO8-1_Lq9tVs81CeC2uaiJvKbspagIfoQV26Xq_K42vmDdP2vAP_UgN8Lwea3OmCcUcoIx-gBGn9m3SqUzrf0yQNCC6SlrZK1_oN2RIjCNpR0eRA2R45ResAjcv2HcmLym2furhiTaxlnj5xZ8XOpL80uqaRsIpVvEXW55Y-B57PPZRxLVyfMcnaA5tZuPf1mHJvByvqDXIr3XvYILsoemflmYq4ZjWveP-J47Bhis4b0m4oVT-K84U2RpZb1VTW_5pq6bIWpozJasGJtuy-QEoXp7NfzqjExaVkehCOfZXyxTfprcL0DYseich61lgwmZWX53adBLfL25HUu5mj9hPoBbaGIUmUeW94ZFZQfRWNDjKaoaGWsr9e4LGnWf59xe_UqiGQOrv8f5u6TTAuhe-lO7PEa49lyEbZNjKD7wGHnn3vml8wEilyADvUv_Q4XtkGJB3epdSNUeKrgq5IMs82KTgCTvxh-eR1y64GVz6YuD_BaNJOoHYijEJe_Tz-YwoqxNSlx7Q32vUUnGKoUoejWHO4v0po54iu6XqhU59hubeoVy0s5pateicZb-ZZZTtjoVFO3LPjNd58EKmxoQswhmKD_6ItYjZPpMkaSXmM2BLBq0WeLB927tA1ez8Wt3tr6ogbibjENiOEujcnK1Jp_GTJ1lGXLWuxzSiwHxv6ENlnWeO1lUbF_de1NcEx2XKy8TIHdknK-s4RcIHAZJlJTlDWmwdWwT2m_4PQqVHKYYiQJF3muKjlM4pLVTZ4d973fciKHSkftt_WMepMCQQjqhpaxML_1Zu44IBEQcbHE7Ctabb5-FmxTV91ukvdaqY_3j1vrj6ZRciKuvIG5zHosxI2cZyQIdJOY_66qoFrImfR_Ceoytsyp_JffqDjUk-KOed0U5Sc-7UrurIRSaQCZhYqGTH00dmj2u7Szk54Cv56SD211Zzb19BDOhYYcrGbMLESuIhFzpJqgfQNovmURt4aeIGJGpSm29IiBLEryiyPROU6xIo2R25bpFnGn3eokKxtf8yX2KgUmJ_yhMHHokUWH5y3No5zL6LrR_hlNkTKiwtYzqoFpdG1WgWfb2oRhzqd77EzTldNhrRqBdvv7YfsyQbupyFlysbQqlFwDdKneg02CkmMu5FjSH_WSH237ZJgTFHp-LIR3ha7zdnnoTd3sj2vB4E8gA0ax-Hds-QIPXMoBQH2Tv2Nl1GPyTyT5f7WnSIFDaE0QIDEJ9G3JTre9Ydeud2cjVqqr28Jv0l-_ovpPAxKgKdpCKo13NxkV-_MQ'
FIREBASE_KEY_PATH = r'C:\Users\Azhar Arshad\Downloads\mobile-app-f270c-firebase-adminsdk-fbsvc-774118213a.json'
PROJECT_ID = 'mobile-app-f270c'

FOLDERS = {
    '/football': 'football'
}

def safe_print(text):
    print(str(text).encode('ascii', 'replace').decode('ascii'))

def get_firebase_token():
    credentials = service_account.Credentials.from_service_account_file(
        FIREBASE_KEY_PATH, 
        scopes=['https://www.googleapis.com/auth/datastore']
    )
    auth_req = google.auth.transport.requests.Request()
    credentials.refresh(auth_req)
    return credentials.token

def get_direct_link(dbx, path):
    try:
        shared_link_metadata = dbx.sharing_create_shared_link_with_settings(path)
        url = shared_link_metadata.url
    except dropbox.exceptions.ApiError as e:
        links = dbx.sharing_list_shared_links(path=path, direct_only=True).links
        if links:
            url = links[0].url
        else:
            return None
    return url.replace('?dl=0', '?raw=1')

def upload_videos():
    print("Getting Firebase Auth Token...")
    fb_token = get_firebase_token()
    
    print("Connecting to Dropbox...")
    dbx = dropbox.Dropbox(DROPBOX_ACCESS_TOKEN)
    
    total_uploaded = 0
    
    for dbx_folder, category_id in FOLDERS.items():
        print(f"\nScanning Dropbox folder: {dbx_folder} for category: {category_id}")
        try:
            results = dbx.files_list_folder(dbx_folder)
            
            for entry in results.entries:
                if isinstance(entry, dropbox.files.FileMetadata) and entry.name.endswith('.mp4'):
                    safe_print(f"Processing: {entry.name}...")
                    
                    direct_url = get_direct_link(dbx, entry.path_display)
                    if not direct_url:
                        safe_print(f"Failed to get link for {entry.name}")
                        continue
                        
                    doc_id = str(uuid.uuid4().hex)
                    
                    doc_data = {
                        "fields": {
                            "id": {"stringValue": doc_id},
                            "videoUrl": {"stringValue": direct_url},
                            "title": {"stringValue": entry.name.replace('.mp4', '')},
                            "description": {"stringValue": f"Best {category_id} shorts!"},
                            "categoryId": {"stringValue": category_id},
                            "categoryName": {"stringValue": category_id.capitalize()},
                            "categoryIcon": {"stringValue": "🎯"},
                            "duration": {"stringValue": "0:30"},
                            "thumbnail": {"stringValue": "https://via.placeholder.com/400x600"},
                            "views": {"integerValue": "0"},
                            "likes": {"integerValue": "0"},
                            "isTrending": {"booleanValue": True},
                            "isFeatured": {"booleanValue": True},
                            "isVipOnly": {"booleanValue": False},
                            "isActive": {"booleanValue": True},
                            "order": {"integerValue": "0"},
                            "publishedAt": {"timestampValue": datetime.now().isoformat() + "Z"}
                        }
                    }
                    
                    # Upload directly via REST API
                    post_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/videos"
                    response = requests.post(post_url, headers={"Authorization": f"Bearer {fb_token}"}, json=doc_data, verify=False)
                    
                    if response.status_code == 200:
                        safe_print(f"Successfully uploaded: {entry.name}")
                        total_uploaded += 1
                    else:
                        safe_print(f"Failed to upload: {entry.name} - {response.text}")
                    
        except dropbox.exceptions.ApiError as err:
            print(f"Folder error [{dbx_folder}]: {err}")
            
    print(f"\n=================================")
    print(f"COMPLETE! Uploaded {total_uploaded} videos.")
    print(f"=================================")

if __name__ == '__main__':
    upload_videos()
