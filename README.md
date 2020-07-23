# NoDB

A database solution for Swift projects.

NoDB is a non relational database that requires no setup at all.
To use NoDB is easy as:
```swift
// Define your model
struct User: DBModel {
     var noDBIndex: Int?
     var noDBIndexes: [String]? = ["hairColor", "age"]
     
     var id: String?
     var hairColor: String?
     var age: Int?
}

// Use the database
let friendsDB = NoDB<User>()

// Get all friends
friendsDB.find(nil) { allUsers in
    
}

// Get all friends whose "hairColor" is "red".
friendsDB.find("hairColor" == "red") { redHairUser in
    
}

// Get all friends whose "age" is greater than 20.
friendsDB.find("age" > 20) { foundUsers in
    
}

```

# Usage:

## NoDB Class:
To use the framework you first need to create an instance of a NoDB class. You can subclass NoDB if you need to add a complex implementation or extract functionality into the Database file.
All interactions with the database will be performed through the NoDB instance. 
* Simple Example:
```swift
let friendsDB = NoDB<User>()
```

* Subclass Example: 
```swift
class FriendsDB: NoDB<User> {
    func customQueryFunction() {
        ...
    }
}

let friendsDB = FriendsDB()
friendsDB.customQueryFunction()
```

## DBModel:
Every object that needs to be saved into the database should conform to DBModel protocol.
The protocol has two basic variables: 
1. **noDBIndex: Int** Used internally to keep track of the index of an object inside the database. DO NOT MODIFY.
2. **noDBIndexes: [String]** A list of strings defining properties that should be indexed. 
* Example:
In this example we have a **User** model with two "custom" properties **dateCreated** and **name**. We want to be able to search and delete users using these two properties so we will add the property names to the **noDBIndexes**.
Note that we are not adding id as an indexed value since the database will automatically index id properties for all models. (More on ids below).
* Create Model Example:
```swift
struct User: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]? = ["dateCreated", "name"]
    
    var id: String?
    var dateCreated: Date?
    var name: String?
}
```

## Indexes:
> NoDB uses indexed tables in order to perform efficient and fast operations. Every database operation you wish to perform will have to be previously added to the **noDBIndexes** of your model.
> Note that for every extra property you wish to index there will be a performance cost since the database will have to manage that extra index for every database operation. So consider indexing only the properties that you will actually use for operations like query and delete.
* Query Example:
```swift
let friendsDB = FriendsDB()
friendsDB
```

## IDs:
All objects that need to be saved in the database are required to have an **id** property. Objects with no **id** will be ignored.
By default the database will automatically index ids for your models for this reason you don't need to add your id property to the **noDBIndexes** array.
Note that the DBModel protocol doesn't require you to have an id property. This is because you can have the name of your id properties be anything you like and each database can have their own id property. 
By default the database will try to pull the **id** value from a property named **"id"** but this can be changed by passing the name of your **id** property when initializing the database.
For now all id properties must be of type String. Support for Integers will be considered in a future update.
* Custom ID Example:
```swift
struct User: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]?
    var userId: String?
}

let usersDB = NoDB<User>(idKey: "userId")
usersDB.find("userId" == "myuserid") { myUser in 
    
}
```

## Queries:
To perform a query you simply call the __find()__ function on a NoDB instance. 
__find()__ takes a single Query object as a parameter.
Query objects can be built using common operators: __"=="__, __">"__, __">="__, __"<"__, __"<="__.
Remember that to perform a query over a model property, the name of the property must be added to the **noDBIndexes** array. This will let the database know thaat it needs to create index for this property key.
In the current version, only single queries are allowed. In a future update we will support compound operations using: && and ||.
* Queries Example:
```swift
struct Car: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]? = ["color", "year", "price"]
    var id: String?
    var color: String?
    var year: Int?
    var price: Double?
}

let carsDB = NoDB<Car>()

// Find all red cars:
carsDB.find("color" == red) { redCars in
    
}

// Find cars that are from the year 2020 and newer:
carsDB.find("year" >= 2020) { newCars in 
    
}

// Find cars that are 5k dollars or cheaper.
carsDB.find("price" <= 5000.0) { cheapCars in 
    
}
```

## Saving Objects:
To save an object into the database you will have to call the __save()__ function.
The save function will use the object's **id** to check wheather it needs to update an existing object or insert it as a new object.
If the object already existed in the database, calling __save()__ again will update the saved object's properties with the new object's properties.
* Saving Example:
```swift
struct Car: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]? = ["color", "year", "price"]
    var id: String?
    var color: String?
    var year: Int?
    var price: Double?
}

let carsDB = NoDB<Car>()

let car = Car(id: "1", 
              color: "red")
              
// Create a car object:
carsDB.save(car) { createdCar in
    print(createdCar) // Output: "id": "1", "color": "red".
}

let updatedCar = Car(id: "1", 
                     year: 2020)
// Update an existing car:
carsDB.save(updatedCar) { updatedCar in 
    print(updatedCar) // Output: "id": "1", "color": "red", "year": 2020. 
    // Note that the car with "id" 1 already existed and the database merged the car's properties together.
}


```

## Persist Data Permanently to the Device:
NoDB is not an actual database program. It is a set of methods over an array of DBModel objects to perform fast operations in memory (Ram).
To save the current state of any of your database you will need to call __saveDB()__ method when appropiate.
You should not call this method often since each NoDB is actually a single file stored all at once. This means that all the objects in a NoDB class will be saved to disk when you call __save()__.
A good place to call __saveDB()__ is on ApplicationWillResignActive or where you know you won't be updating the database any time soon.
NoDB uses KeyedArchiver to convert the objects to data using Codable and store them in the device.
When you initialize an instance of a NoDB class, the file will be loaded into memory and the data will be converted to Model Objects for the database to work. 
Loading and saving of the database file happens in the background and it will not block the UI. This will happen really fast as long as you don't have tens of thousands of objects stored in a single database file.
By default the name of the database files will be the same as your model classes. Ex: A **User** model's database file will be called **user**.
You can customize the name of the database file by passing a **name** property to the NoDB initializer.
Support for encrypting the Database files will be added in a future update.
* Custom DB File Name Example:
```swift
// Custom database file name:
// - Note: In this example, not having a custom name for the friends thatabase would overrid the Users database.
// In this case the "usersDB" file name will be "user" and the "friendsDB" will be friend.
let usersDB = NoDB<User>()
let friendsDB = NoDB<User>(name: "friend")
```
> Imagine you have a screen where the user enters to see all their friends.
> In this case you would call the server to get the list of friends and then store them locally on the device using NoDB.
> A good place to call "save()" here would be after the user exits this screen since you won't be updating the friendsDB any more unless the user comes back to friends screen.
> Example:
```swift
let friendsDB = NoDB<User>(name: "friend")

func backButtonTapped() {   
    friendsDB.saveDB()
}
```
