Caravan Server
===

API Layout (How you get things)
===

Sign users up (/newuser)
---

POST Request:
```
{
   "username" : username_var,
   "email" : email_var,
   "password" : password_var
}
```
Response:
```
{
   "id" : new_user_id (or -1 if error)
}
```

Get user info (/user/{id})
---

GET Request:
```
/user/{id}
```
Response:
```
{
  "active": (1/0),
  "batteryPercentage": (0-100),
  "cartype": car_type_var,
  "email": user_email,
  "gasPercentage": (0-100),
  "groupid": group_id,
  "heading": heading_,
  "id": user_id (or -1 if user not found),
  "latitude": user_lat,
  "longitude": user_long,
  "password": user_password,
  "speed": user_speed,
  "timestamp": timestamp,
  "username": user_name
}
```

Set User Coordinates (/setusercords)
---
POST Request:
```
{
   "logitude" : log_var,
   "latitude" : lat_var,
   "userid" : id_var
}
```
Response:
```
true (or false depending on if it was updated)
```

Create New Group (/newgroup)
---
POST Request:
```
{
   "startinglong" : start_log_var,
   "startinglat" : start_lat_var,
   "endinglong" : end_long_var,
   "endinglat" : end_lat_var,
   "userid" : id_var
}
```
Response:
```
{
   "id" : group_id
}
```

Add to Group (/addtogroup)
---
POST Request:
```
{
   "userid" : id_var,
   "groupid" : groupid_var
}
```
Response:
```
true (or false if not added)
```

Join User Group (/joinusergroup)
---
POST Request:
```
{
   "userid" : id_var,
   "usertojoinid" : id2_var
}
```
Response:
```
{
   "groupid" : groupid_var
}
```

Change Final Destination (/changeFinalDestination)
---
POST Request:
```
{
   "groupid" : groupid_var,
   "endinglong" : ending_longitude_var,
   "endinglat" : ending_latitude_var
}
```
Response:
```
{
   "groupid" : groupid
}
```

Add Destination to Group (/addDestination)
---
POST Request:
```
{
   "groupid" : groupid_var,
   "longitude" : longitude_var,
   "latitude" : latitude_var,
   "userid" : userid_var
}
```
Response:
```
{
   "groupid" : groupid
}
```

Get Group Destintation (/getdestination)
---
POST Request:
```
{
   "groupid" : groupid_var
}
```
Response:
```
{
   "longitude" : destination_longitude,
   "latitude" : destination_latidtude,
   "userid" : user_who_created_destintation,
   "type" : "final" (or "intermediate")
}
```

Get Group Member Info (/getgroupinfo)
---
POST Request:
```
{
   "groupid" : groupid_var,
   "userid" : userid_var
}
```
Response:
```
[
   {
      "longitude" : user_longitude,
      "latitude" : user_latitude,
      "userid" : user_id,
      "gasPercentage" : user_gas_percentage,
      "batteryPercentage" : user_battery_percentage,
      "username" : user_username
   }
]

Table Layout (What you can get)
===
The format is the following

```sql
nameOfItem (type:max_length(, decimal length))
```

Users
---


```sql
id (int:11)
active (bool:1)
username (string:255)
password (string:255)
email (string:255)
cartype (string:255)
latitude (double:3,6)
longitude (double:3,6)
speed (double:3,6)
heading (double:3,6)
gasPercentage (double:3,6)
batteryPercentage (double:3,6)
groupid (int:11)
timestamp (timestamp)
```

Groups
---

```sql
id (int:11)
active (bool:1)
groupcreater (int:11)
startingLatitude (double:3,6)
startingLongitude (double:3,6)
endingLatitude (double:3,6)
endingLongitude (double:3,6)
timestamp (timestamp)
```

Users To Group (might not need this)
---

```sql
id (int:11)
active (bool:1)
userid (int:11)
groupid (int:11)
timestamp (timestamp)
```

Destinations To Groups
---

```sql
id (int:11)
active (bool:1)
userid (int:11)
groupid (int:11)
longitude (double:3,6)
latitude (double:3,6)
```
