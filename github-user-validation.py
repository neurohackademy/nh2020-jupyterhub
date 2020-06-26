import requests
import requests_cache
import time

# ensure we cache our requests so its quick to redo them
requests_cache.install_cache('github_usernames')

# enter a username per line below
users = """

"""

invalid_github_users = []
for user in users.splitlines():
    if not user:
        continue

    r = requests.get("https://github.com/" + user)
    if not r.ok:
        invalid_github_users.append(user)

    print(user + ":" + str(r.ok))

print()
print("These are the invalid github users identified:")
print(invalid_github_users)
