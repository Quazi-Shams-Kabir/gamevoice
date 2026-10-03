#!/usr/bin/env python3
"""python make_token.py <name> [room]  -> prints a join token (12h)."""
import os, sys
from datetime import timedelta
from livekit import api   # pip install livekit-api

key, secret = os.environ["LIVEKIT_API_KEY"], os.environ["LIVEKIT_API_SECRET"]
name = sys.argv[1]
room = sys.argv[2] if len(sys.argv) > 2 else "squad"

print(api.AccessToken(key, secret)
      .with_identity(name).with_name(name)
      .with_ttl(timedelta(hours=12))
      .with_grants(api.VideoGrants(room_join=True, room=room))
      .to_jwt())
