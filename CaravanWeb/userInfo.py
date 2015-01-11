#page to get the user info from the database

import web, json, pymysql, pymysql.cursors, hashlib, re

urls = (
   '/user/(.*)', 'getUserData',
   '/newuser', 'createNewUser',
   "/setcords", "setLatLong"
)

class setLatLong:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data requested is there
      if("longitude" in postArray and "latitude" in postArray
         and "userid" in postArray):

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #execute the command to insert a user into the database
         cur.execute("UPDATE users SET latitude = %s, longitude = %s WHERE id = %s",
            [postArray.latitude, postArray.longitude, postArray.userid])

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps(True, sort_keys=True, indent=2,
               separators=(',', ': '))

      else:
         return json.dumps(False, sort_keys=True, indent=2,
               separators=(',', ': '))

class getUserData:
   def GET(self, userid):

      #set the return type
      web.header('Content-Type', 'application/json')

      #check to make sure we are looking for a number only
      finder = re.compile("^[0-9]*$")

      #if we are only looking for a number
      if finder.match(userid):

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan', cursorclass=pymysql.cursors.DictCursor)
         cur = conn.cursor()

         #excute to get the users data
         cur.execute("SELECT * FROM users WHERE id = %s", [userid,])

         #set the user data for output
         userArray = cur.fetchone()

         #if the user is found
         if userArray != None:

            userArray["timestamp"] = str(userArray["timestamp"])

            #commit the changes
            conn.commit()

            #close the database connection
            cur.close()
            conn.close()

            return json.dumps(userArray, sort_keys=True, indent=2,
               separators=(',', ': '))

         else:

            return json.dumps({"id": -1}, sort_keys=True, indent=2,
               separators=(',', ': '))




      #if tried to search for something other than a number
      else:

         return json.dumps({"id": -1}, sort_keys=True, indent=2,
               separators=(',', ': '))

class createNewUser:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #make sure all info we need is there
      if ('username' in postArray and "password" in postArray
         and "email" in postArray):

         #generate the hash password
         hashpass = hashlib.sha1(postArray.password).hexdigest()

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #execute the command to insert a user into the database
         cur.execute("INSERT INTO users(username, password, email) VALUES(%s, %s, %s)",
            [postArray.username, hashpass, postArray.email])

         #find out the new users id
         cur.execute("SELECT id FROM users WHERE username = %s AND password = %s",
            [postArray.username, hashpass])

         #create the return dictonary
         returnDict = cur.fetchone()

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         #return the new created user id
         return json.dumps(returnDict, sort_keys=True, indent=2,
            separators=(',', ': '))

      #if we did not recive the correct data
      else:

         #return error code
         return json.dumps({"id": -1}, sort_keys=True, indent=2,
               separators=(',', ': '))

if __name__ == "__main__":
   app = web.application(urls, globals())
   app.run()
