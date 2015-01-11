#page to get the user info from the database

import web, json, pymysql, pymysql.cursors, hashlib, re

urls = (
   '/user/(.*)', 'getUserData',
   '/newuser', 'createNewUser',
   "/setusercords", "setLatLong",
   "/newgroup", "createNewGroup",
   "/addtogroup", "addUserToGroup",
   "/joinusergroup", "joinUserGroup",
   "/changefinaldestination", "changeFinalDestination",
   "/adddestination", "addDestination",
   "/getdestination", "getDestination",
   "/getgroupinfo", "getGroupInfo"
)

class getGroupInfo:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data required is there
      if "groupid" in postArray and "userid" in postArray:

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #get the long/lat data if there is some
         cur.execute('''SELECT longitude, latitude, id, gasPercentage,
            batteryPercentage, username FROM users
            WHERE groupid = %s and id != %s''',
            [postArray.groupid, postArray.userid])

         #create blank list of users
         userinfo = list()

         #fetch the destination data
         for row in cur:

            #create blank dictinary
            newUser = dict()

            newUser["longitude"] = row[0]
            newUser["latitude"] = row[1]
            newUser["userid"] = row[2]
            newUser["gasPercentage"] = row[3]
            newUser["batteryPercentage"] = row[4]
            newUser["username"] = row[5]
            userinfo.append(newUser)

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps(userinfo, sort_keys=True, indent=2,
            separators=(',', ': '))

      else:

         DestOutput = []

         return json.dumps(DestOutput, sort_keys=True, indent=2,
               separators=(',', ': '))

class getDestination:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data required is there
      if "groupid" in postArray:

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #get the long/lat data if there is some
         cur.execute('''SELECT longitude, latitude, userid FROM
            destinationsToGroups WHERE groupid = %s ORDER BY timestamp DESC
            LIMIT 1''', [postArray.groupid])

         #fetch the destination data
         Destdata = list(cur.fetchone())

         #set the destination type
         Destdata.append("intermediate")

         #if there is no intermediate destination
         if Destdata == None:

            #get the long/lat final data
            cur.execute('''SELECT endinglongitude, endinglatitude,
               groupcreater FROM groups where id = %s''', [postArray.groupid])

            #fetch the destination data
            Destdata = cur.fetchone()

            #set the destination type
            Destdata.append("final")

         #make the dictionary for output
         DestOutput = {"longitude": Destdata[0], "latitude": Destdata[1],
            "userid": Destdata[2], "type": Destdata[3]}

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps(DestOutput, sort_keys=True,
            indent=2, separators=(',', ': '))

      else:

         DestOutput = {"longitude": -1, "latitude": -1,
            "userid": -1, "type": "invalid"}

         return json.dumps(DestOutput, sort_keys=True, indent=2,
               separators=(',', ': '))

class addDestination:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data required is there
      if ("groupid" in postArray and "longitude" in postArray
         and "latitude" in postArray and "userid" in postArray):

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #add a long/lat to the group
         cur.execute('''INSERT INTO destinationsToGroups(userid, groupid,
            longitude, latitude) VALUES(%s, %s, %s, %s)''',
            [postArray.userid, postArray.groupid, postArray.longitude,
            postArray.latitude])

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps({"groupid" : postArray.groupid},
            sort_keys=True, indent=2, separators=(',', ': '))

      else:
         return json.dumps({"groupid" : -1}, sort_keys=True, indent=2,
               separators=(',', ': '))

class changeFinalDestination:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data required is there
      if ("groupid" in postArray and "endinglong" in postArray
         and "endinglat" in postArray):

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #change the final lat/long of a group
         cur.execute('''UPDATE groups SET endingLatitude = %s,
            endingLongitude = %s WHERE id = %s''', [postArray.endinglat,
            postArray.endinglong, postArray.groupid])

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps({"groupid" : postArray.groupid},
            sort_keys=True, indent=2, separators=(',', ': '))

      else:
         return json.dumps({"groupid" : -1}, sort_keys=True, indent=2,
               separators=(',', ': '))

class joinUserGroup:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data required is there
      if "userid" in postArray and "usertojoinid" in postArray:

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #get the group id of the user we want to join
         cur.execute("SELECT groupid FROM users WHERE id = %s",
            [postArray.usertojoinid])

         #fetch the group id
         groupid = cur.fetchone()[0]

         #insert the user into the group
         cur.execute('''INSERT INTO usersToGroups(userid, groupid)
            VALUES(%s, %s)''',
            [postArray.userid, groupid])

         #change the groupid of the user
         cur.execute("UPDATE users SET groupid = %s WHERE id = %s",
            [groupid, postArray.userid])

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps({"groupid" : groupid}, sort_keys=True, indent=2,
               separators=(',', ': '))

      else:
         return json.dumps({"groupid" : -1}, sort_keys=True, indent=2,
               separators=(',', ': '))

class addUserToGroup:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data required is there
      if "userid" in postArray and "groupid" in postArray:

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #execute the command to insert the user/group relation
         cur.execute('''INSERT INTO usersToGroups(userid, groupid)
            VALUES(%s, %s)''', [postArray.userid, postArray.groupid])

         #update the group id in the user table
         cur.execute("UPDATE users SET groupid = %s WHERE id = %s",
            [postArray.groupid, postArray.userid])

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

class createNewGroup:
   def GET(self):
      return "POST only"

   def POST(self):

      #set the return type
      web.header('Content-Type', 'application/json')

      #create the array to get the post data
      postArray = web.input()

      #if all data requested is there
      if("startinglong" in postArray and "startinglat" in postArray
         and "endinglong" in postArray and "endinglat" in postArray and
         "userid" in postArray):

         #connect to the database
         conn = pymysql.connect(host='127.0.0.1', user='caravan',
            passwd='5RykXMGvyn', db='caravan')
         cur = conn.cursor()

         #execute the command to insert the group into the database
         cur.execute('''INSERT INTO groups(startingLatitude, startingLongitude,
            endingLatitude, endingLongitude, groupcreater)
            VALUES(%s, %s, %s, %s, %s)''', [postArray.startinglat,
            postArray.startinglong, postArray.endinglat, postArray.endinglong,
            postArray.userid])

         #get the group id
         cur.execute('''SELECT id FROM groups WHERE
            groupcreater = %s ORDER BY timestamp DESC LIMIT 1''',
            [postArray.userid])

         #set the id data for output
         GroupArray = dict()
         tempArray = cur.fetchone()
         GroupArray["id"] = tempArray[0]

         #change the group in the user table
         cur.execute("UPDATE users SET groupid = %s WHERE id = %s",
            [GroupArray["id"], postArray.userid])


         #insert the user into the group
         cur.execute('''INSERT INTO usersToGroups(userid, groupid)
            VALUES(%s, %s)''', [postArray.userid, 2])

         #commit the changes
         conn.commit()

         #close the database connection
         cur.close()
         conn.close()

         return json.dumps(GroupArray, sort_keys=True, indent=2,
               separators=(',', ': '))

      else:
         return json.dumps({"id": "-1"}, sort_keys=True, indent=2,
               separators=(',', ': '))

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
         cur.execute('''UPDATE users SET latitude = %s, longitude = %s WHERE
            id = %s''', [postArray.latitude, postArray.longitude,
            postArray.userid])

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
            passwd='5RykXMGvyn', db='caravan',
            cursorclass=pymysql.cursors.DictCursor)
         cur = conn.cursor()

         #excute to get the users data
         cur.execute("SELECT * FROM users WHERE id = %s", [userid,])

         #set the user data for output
         userArray = cur.fetchone()

         #if the user is found
         if userArray != None:

            userArray["timestamp"] = str(userArray["timestamp"])

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
         cur.execute('''INSERT INTO users(username, password, email)
            VALUES(%s, %s, %s)''', [postArray.username, hashpass,
            postArray.email])

         #find out the new users id
         cur.execute('''SELECT id FROM users WHERE username = %s
            AND password = %s''', [postArray.username, hashpass])

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
