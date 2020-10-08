class User {
  String name;
  int pk;
  List<ShoppingList> shoppingLists;

  User({this.name, this.pk}) {
    this.shoppingLists = new List<ShoppingList>();
  }
}

class ShoppingList {
  String name;
  User owner;
  List<User> editors;
  int uniqueID;
  List<ShoppingListObject> items;
  int pk;

  ShoppingList({this.name, this.owner, this.uniqueID, this.pk}) {
    this.items = new List<ShoppingListObject>();
    this.editors = new List<User>();
  }
}

class Product {
  String name;
  int pk;

  Product({this.name, this.pk});
}

class ShoppingListObject {
  Product product;
  String units;
  double amount;
  User userAdded;
  bool isBought;

  ShoppingListObject({this.product, this.units, this.amount, this.userAdded, this.isBought});

  String getUnitsText() {
    if (this.units == "units")
      return "יחידות";
    return 'ק"ג';
  }
}

class Error {
  String errorStatement;

  Error({this.errorStatement});
}