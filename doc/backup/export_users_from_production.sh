#!/usr/bin/env bash

mongoexport -h ds031087.mongolab.com --port 31087 -d heroku_app2916299 -u heroku_app2916299 -p 3s0f6secs7fdcnj98ivc1rtll6 -c users > users.json
