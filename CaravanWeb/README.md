Caravan Server
===

API Layout (How you get things)
----

Sign users up (/newuser)
---

POST Request:
```json
{
   "username" : username_var,
   "email" : email_var,
   "password" : password_var
}
```
Returns:
```json
{
"id" : new_user_id (or -1 if error)
}
```

Get user info (/user/{id})
---

GET Request:
```url
/user/{id}
```
Returns:
```json
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

Table Layout (What you can get)
----
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
