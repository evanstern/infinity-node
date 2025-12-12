import json
from urllib.parse import urlparse
from collections import defaultdict
import sys

def get_host(uri):
    try:
        return urlparse(uri).netloc
    except:
        return uri

def load_items(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)

def find_duplicates(items):
    name_groups = defaultdict(list)
    login_groups = defaultdict(list)

    for item in items:
        if item.get('type') != 1: # 1 is Login
            continue

        # Group by Name
        name = item.get('name')
        if name:
            name_groups[name].append(item)

        # Group by Username + Host
        login = item.get('login', {})
        username = login.get('username')
        uris = login.get('uris', [])

        if username and uris:
            for uri_obj in uris:
                uri_val = uri_obj.get('uri')
                if uri_val:
                    host = get_host(uri_val)
                    if host:
                        key = (username, host)
                        if not any(i['id'] == item['id'] for i in login_groups[key]):
                            login_groups[key].append(item)

    duplicates = []
    seen_ids = set()

    # Process Name Duplicates
    for name, group in name_groups.items():
        if len(group) > 1:
            group_ids = sorted([i['id'] for i in group])
            group_key = tuple(group_ids)
            if group_key in seen_ids:
                continue
            seen_ids.add(group_key)
            duplicates.append({
                "reason": f"Same Name: '{name}'",
                "items": process_group(group)
            })

    # Process Login Duplicates
    for (username, host), group in login_groups.items():
        if len(group) > 1:
            group_ids = sorted([i['id'] for i in group])
            group_key = tuple(group_ids)
            if group_key in seen_ids:
                continue
            seen_ids.add(group_key)
            duplicates.append({
                "reason": f"Same Username '{username}' on Host '{host}'",
                "items": process_group(group)
            })

    return duplicates

def process_group(items):
    # Sort by revision date descending (newest first)
    # ISO format sorts correctly as string
    items.sort(key=lambda x: x.get('revisionDate') or "", reverse=True)

    simple_items = []

    # Check for exact content matches (username, password, uris)
    # The first item is the newest, we keep it by default.
    # If older items match the newest item's sensitive data, mark them for deletion.

    newest = items[0]
    newest_login = newest.get('login', {})
    newest_user = newest_login.get('username')
    newest_pass = newest_login.get('password')
    newest_uris = sorted([u.get('uri') for u in newest_login.get('uris', [])])

    for i, item in enumerate(items):
        login = item.get('login', {})
        username = login.get('username')
        password = login.get('password')
        uris = sorted([u.get('uri') for u in login.get('uris', [])])

        action = "keep"

        # Heuristic: If it's not the newest, AND it has same username/password/uris as newest, mark delete
        # Only if we actually have values to compare (don't delete empty stuff based on empty matches)
        has_content = (username or password or uris)

        if i > 0 and has_content:
            if username == newest_user and password == newest_pass and uris == newest_uris:
                action = "delete"

        simple_items.append({
            "id": item.get('id'),
            "name": item.get('name'),
            "username": username,
            "password_preview": password[:5] + "..." if password else None,
            "uris": [u.get('uri') for u in login.get('uris', [])],
            "revisionDate": item.get('revisionDate'),
            "action": action
        })

    return simple_items

if __name__ == "__main__":
    items = load_items("bw_items.json")
    dupes = find_duplicates(items)

    with open("potential_duplicates.json", "w") as f:
        json.dump(dupes, f, indent=2)

    print(f"Found {len(dupes)} sets of potential duplicates.")
