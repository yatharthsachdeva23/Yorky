import urllib.request
import re
import json

url = 'https://www.youtube.com/shorts/dpTHfuBYClo'
req = urllib.request.Request(
    url,
    headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9'
    }
)
with urllib.request.urlopen(req, timeout=20) as resp:
    html = resp.read().decode('utf-8', 'ignore')

start = html.find('var ytInitialData = ')
end = html.find(';</script>', start)
data_str = html[start+len('var ytInitialData = '):end]
data_obj = json.loads(data_str)

api_key_m = re.search(r'\"INNERTUBE_API_KEY\":\"([^\"]+)\"', data_str)
api_key = api_key_m.group(1) if api_key_m else None
client_ver_m = re.search(r'\"INNERTUBE_CLIENT_VERSION\":\"([^\"]+)\"', data_str)
client_ver = client_ver_m.group(1) if client_ver_m else "2.20240301.00.00"

token = None
for p in data_obj.get('engagementPanels', []):
    header = p.get('engagementPanelSectionListRenderer', {}).get('header', {}).get('engagementPanelTitleHeaderRenderer', {})
    sub_menu = header.get('menu', {}).get('sortFilterSubMenuRenderer', {})
    for item in sub_menu.get('subMenuItems', []):
        if item.get('title') in ('Top', 'Newest'):
            token = item.get('serviceEndpoint', {}).get('continuationCommand', {}).get('token')
            break
    if token:
        break

browse_url = f"https://www.youtube.com/youtubei/v1/browse?key={api_key}"
headers = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}
payload = {
    "context": {
        "client": {
            "clientName": "WEB",
            "clientVersion": client_ver,
            "hl": "en",
            "gl": "US"
        }
    },
    "continuation": token
}
post_req = urllib.request.Request(browse_url, data=json.dumps(payload).encode('utf-8'), headers=headers)
with urllib.request.urlopen(post_req, timeout=20) as resp:
    result = json.loads(resp.read().decode('utf-8', 'ignore'))

# Look at frameworkUpdates
fu = result.get('frameworkUpdates', {})
ebu = fu.get('entityBatchUpdate', {})
mutations = ebu.get('mutations', [])
print(f"Number of mutations: {len(mutations)}")

for i, m in enumerate(mutations):
    p = m.get('payload', {})
    print(f"\nMutation {i}:")
    print(f"  Payload keys: {list(p.keys())}")
    if 'commentSharedEntityPayload' in p:
        cep = p['commentSharedEntityPayload']
        print(f"  commentSharedEntityPayload found!")
        print(f"  Properties keys: {list(cep.get('properties', {}).keys())}")
        cid = cep.get('properties', {}).get('commentId', 'N/A')
        print(f"  Comment ID: {cid}")
        author = cep.get('author', {}).get('displayName', 'N/A')
        print(f"  Author: {author}")
        raw_text = cep.get('properties', {}).get('content', {}).get('content', 'N/A')
        print(f"  Raw text: {raw_text[:100] if raw_text else 'N/A'}")
        reply_lvl = cep.get('properties', {}).get('replyLevel', 'N/A')
        print(f"  Reply level: {reply_lvl}")
        # Check for pinned
        is_pinned = 'pinned' in str(cep.get('properties', {})).lower() or 'pinned' in str(cep.get('toolbar', {})).lower()
        print(f"  Is pinned: {is_pinned}")
        # Check for hearted
        is_hearted = 'heartActiveTooltip' in str(cep.get('toolbar', {}))
        print(f"  Is hearted: {is_hearted}")
        like_count_str = cep.get('toolbar', {}).get('likeCountNotliked', '0')
        import re as re_mod
        likes_int = int(re_mod.sub(r'[^\\d]', '', str(like_count_str)) or 0)
        print(f"  Like count: {likes_int}")
    elif 'commentEntityPayload' in p:
        cep = p['commentEntityPayload']
        print(f"  commentEntityPayload found (old format)")