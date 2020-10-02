# NoDB

A database solution for Swift projects.

NoDB is a non relational database that requires no setup at all.
To use NoDB is easy as:
```swift
// Define your model, conforming to DBModel protocol. It extends Codable to save and load objects to Models.
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
> **Note:** If you have a custom Encoding method you must pass along this instance with the same key as the variable name.
2. **noDBIndexes: [String]** A list of strings defining properties that should be indexed. 
* Example:
In this example we have a **User** model with two "custom" properties **dateCreated** and **name**. We want to be able to search and delete users using these two properties so we will add the property names to the **noDBIndexes**.
> Note that we are not adding id as an indexed value since the database will automatically index id properties for all models. (More on ids below).
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
> **Note:** Always use optional properties in your models, NoDB uses Codable to convert saved data to Model Objects, this process will fail if the Encoder/Decoder are not able to assign a non optional property from objects that were previously stored. 
Consider the following initial state where your model only contains a few property and after saving a few objects you add more non-optional properties to it. The next time you launch the app after defining the new non-optional properties, your database will have no saved objects since it has failed to convert the previous data to the new Objects on the Coding process:
```swift
struct User: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]? = ["name"]
    
    var id: String?
    var name: String
}
// First, create the DB instance and save a user with a name property.
let usersDB = NoDB<User>()
let firstUser = User(name: "John")
usersDB.save(firstUser)

// Next, define a new dateCreated property to the model and try finding the previously stored user. 
// It will fail to find any object since the previously stored Users had no dateCreated property and it is defined as a non-optional property.
struct User: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]? = ["name", "dateCreated"]
    
    var id: String?
    var name: String
    var dateCreated: Date
}
let usersDB = NoDB<User>()
usersDB.find() { usersFound in 
    // usersFound == nil 
}

// If we change the dateCreated property to be an optional the DB will be able to load previously stored users by simply assigning dateCreated property to null for users who don't have a value this property yet.
struct User: DBModel {
    var noDBIndex: Int?
    var noDBIndexes: [String]? = ["name", "dateCreated"]
    
    var id: String?
    var name: String
    var dateCreated: Date?
}
let usersDB = NoDB<User>()
usersDB.find() { usersFound in 
    // usersFound: [ { name: "John", dateCreated: nil } ]  
}
```


## Indexes:
NoDB uses indexed tables in order to perform efficient and fast operations. Every database operation you wish to perform on your model's properties will have to be previously added to the **noDBIndexes** of your model.
> Note that for every extra property you wish to index there will be a performance cost since the database will have to manage that extra index for every database operation. So consider indexing only the properties that you will actually use for database operations.


## IDs:
All objects that need to be saved in the database are required to have an **id** property. Objects with no **id** will be ignored.
By default the database will automatically index ids for your models for this reason you don't need to add your id property to the **noDBIndexes** array.
> Note that the DBModel protocol doesn't require you to have an id property. This is because you can have the name of your id properties be anything you like and each database can have their own id property. 
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
Remember that to perform a query over a model property, the name of the property must be added to the **noDBIndexes** array. This will let the database know that it needs to create an index for this property key.
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

// Find all elements in a DB:
carsDB.find() { allCars in 

}

// Find a single element:
carsDB.findFirst("id" == carId) { car in

}

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
Optionally you can use find synchornous functions but keep in mind that the main thread might get blocked for a while depending on how heavy the find operation is.
* Query Synchronous Example:
```swift
let allCars = carsDB.findSync()

let myCar = carsDB.findFirst("id" == cardId)
```


## Saving Objects:
To save an object into the database you call the __save()__ function.
The save function will use the object's **id** to check wheather it needs to update an existing object or insert it as a new one.
If the object already exists in the database, calling __save()__ again will update the saved object's properties with the new object's properties.
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
print(updatedCar) // Output: { "id": "1", "color": "red", "year": 2020 } 
    // Note that the car with "id" 1 already existed and the database merged the car's properties together.
}
```


## Persist Data Permanently to the Device:
NoDB is not an actual database program. It is a set of methods over an array of DBModel objects to perform fast operations in memory (Ram).
To save the current state of any of your database you will need to call __saveDB()__ method when appropiate.
You should not call this method very often since each NoDB is actually a single file stored all at once. This means that all the objects in a NoDB class will be saved to disk when you call __save()__.
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
Imagine you have a screen where the user enters to see all their friends.
In this case you would call the server to get the list of friends and then store them locally on the device using NoDB.
A good place to call "save()" here would be after the user exits this screen since you won't be updating the friendsDB any more unless the user comes back to friends screen.
Example:
```swift
let friendsDB = NoDB<User>(name: "friend")

func backButtonTapped() {   
    friendsDB.saveDB()
}
```
