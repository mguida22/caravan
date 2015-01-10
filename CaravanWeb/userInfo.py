#page to get the user info from the database

import web, json

urls = (
   '/user/(.*)', 'getUserData',

)

class getUserData:
        def GET(self, name):
                pyDict = {name:1,'two':2}
                web.header('Content-Type', 'application/json')
                return json.dumps(pyDict)

if __name__ == "__main__":
        app = web.application(urls, globals())
        app.run()