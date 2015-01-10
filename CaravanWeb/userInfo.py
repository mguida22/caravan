#page to get the user info from the database

import web, json, pymysql, hashlib

urls = (
   '/user/(.*)', 'getUserData',
   '/newuser', 'createNewUser'

)

class getUserData:
   def GET(self, name):
      pyDict = {name:1,'two':2}
      web.header('Content-Type', 'application/json')
      return json.dumps(pyDict)

class createNewUser:
   def GET(self):
      return "POST only"

   def POST(self):

      #we are going to return json
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #make sure all info we need is there
      if ('username' in postArray and "password" in postArray
         and "email" in postArray):

         #generate the hash password
         hashpass = hashlib.sha1(postArray.password).hexdigest()

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan', passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #execute the command to insert a user into the database
         cur.execute("INSERT INTO users(username, password, email) VALUES(%s, %s, %s)",
            [postArray.username, hashpass, postArray.email])

         #find out the new users id
         cur.execute("SELECT id FROM users WHERE username = %s AND password = %s",
            [postArray.username, hashpass])

         #create the return dictonary
         returnDict = dict()

         #set the new id to be returned
         for row in cur:
            returnDict["id"] = row[0]

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         #return the new created user id
         return json.dumps(returnDict)

      #if we did not recive the correct data
      else:

         #return error code
         return json.dumps({"id": -1})

if __name__ == "__main__":
   app = web.application(urls, globals())
   app.run()
