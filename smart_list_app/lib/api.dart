/// This file outputs all the functions needed to communicate with the app's
/// backend.
/// Written By: Gefen Hajaj

import 'dart:convert';
import 'dart:async';
import 'package:smart_list_app/classes.dart';
import 'package:http/http.dart';

class Api {
  // static final String baseUrl = "10.0.2.2:8000";  // avd
  // static final String baseUrl = "172.20.10.2:8000";  // through hotspot
  static final String baseUrl = "192.168.1.31:8000";  // for android

  /// Create and register a new user.
  static Future createUser(userInfo) async {
    final url = Uri.http(baseUrl, "/smartlist/user/register/");
    final Response response =  await post(url, body: jsonEncode(userInfo));
    final userMap = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return new User(name: userMap['name'], pk: userMap['pk']);
    }
    else {
      return new Error(errorStatement: userMap['error']);
    }
  }

  /// Gets all the user lists and adds them to the user object
  static Future getUserLists(User user) async {
    final getParams = {
      "pk": user.pk.toString()
    };
    List<ShoppingList> shoppingLists = new List<ShoppingList>();
    final url = Uri.http(baseUrl, "smartlist/user/lists/", getParams);
    final Response response = await get(url);
    final responseMap = jsonDecode(response.body);
    if (response.statusCode == 200) {
      for (String pk in responseMap.keys) {
        final shoppingListData = responseMap[pk];

        // Check who the owner is:
        User owner;
        if (shoppingListData['owner_pk'] == user.pk)
          owner = user;
        else
          owner = new User(
            name: shoppingListData['owner_name'],
            pk: shoppingListData['owner_pk']
          );

        // Create the shopping list and add it to our user
        ShoppingList newShoppingList = new ShoppingList(
          name: shoppingListData['name'],
          owner: owner,
          uniqueID: int.parse(shoppingListData['unique_id']),
          pk: int.parse(pk),
        );
        shoppingLists.add(newShoppingList);
      }
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
    user.shoppingLists = shoppingLists;
    return;
  }


  static Future<List<ShoppingListObject>> getShoppingListItems(ShoppingList shoppingList) async {
    final getParams = {
      "pk": shoppingList.pk.toString()
    };
    List<ShoppingListObject> shoppingListItems = new List<ShoppingListObject>();
    final url = Uri.http(baseUrl, "smartlist/list/objects/", getParams);
    final Response response = await get(url);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      for (String pk in responseMap.keys) {
        final shoppingListItemData = responseMap[pk];

        // Create the shopping list item and add it to the final list
        ShoppingListObject newShoppingListItem = new ShoppingListObject(
          pk: int.parse(pk),
          product: new Product(
              name: shoppingListItemData['name'], pk: shoppingListItemData['product_pk']),
          units: shoppingListItemData['units'],
          amount: shoppingListItemData['amount'],
          userAdded: new User(name: shoppingListItemData['user_added_name'],
              pk: shoppingListItemData['user_added_pk']),
          isBought: shoppingListItemData['is_bought'],
        );
        shoppingListItems.add(newShoppingListItem);
      }
    }
    else {
      return null;
    }
    return shoppingListItems;
  }

  /// This function creates a new list for the user.
  /// It returns the new list object.
  /// Note that the name cannot be empty!
  static Future createShoppingList(User user, String name) async {
    ShoppingList newShoppingList = new ShoppingList(owner: user, name: name);
    final url = Uri.http(baseUrl, "smartlist/list/create/");
    String body = json.encode({
      "user_pk": user.pk,
      "name": name
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      newShoppingList.pk = responseMap['pk'];
      newShoppingList.uniqueID = int.parse(responseMap['unique_id']);
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
    return newShoppingList;
  }

  /// This function adds a user to a list.
  /// It returns the new list object.
  static Future joinList(User user, String uniqueID) async {
    int uniqueIDInt = int.parse(uniqueID, onError: (e) => null);
    if (uniqueIDInt == null)
      return Error(errorStatement: "Unique id must be number");

    ShoppingList newShoppingList = new ShoppingList(uniqueID: uniqueIDInt);
    final url = Uri.http(baseUrl, "smartlist/user/addlist/");
    String body = json.encode({
      "user_pk": user.pk,
      "list_unique_id": uniqueIDInt
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      newShoppingList.pk = responseMap['pk'];
      newShoppingList.name = responseMap['name'];
      newShoppingList.owner = new User(name: responseMap['owner_name'], pk: responseMap['owner_pk']);
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
    return newShoppingList;
  }

  /// Create a new item and add it to a list.
  /// returns the new shopping list item.
  static Future addItemToList(User user, ShoppingList shoppingList, String productName, String units, double amount) async {
    if (productName == "")
      return Error(errorStatement: "product name must not be empty");

    ShoppingListObject newItem = new ShoppingListObject(
      product: new Product(name: productName),
      units: units,
      amount: amount,
      userAdded: user,
      isBought: false
    );
    final url = Uri.http(baseUrl, "smartlist/list/add/");
    String body = json.encode({
      "product_name": productName,
      "user_pk": user.pk,
      "list_pk": shoppingList.pk,
      "units": units,
      "amount": amount
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      newItem.product.pk = responseMap['product_pk'];
      newItem.pk = responseMap['pk'];
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
    return newItem;
  }

  /// Change an item - the amount, the unit or the name.
  /// returns null on success and error on failure.
  static Future changeListItem(User user, ShoppingListObject item) async {
    final url = Uri.http(baseUrl, "smartlist/item/change/");
    String body = json.encode({
      "pk": item.pk,
      "amount": item.amount,
      "units": item.units,
      "name": item.product.name
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }

  static Future deleteShoppingList(User user, ShoppingList shoppingList) async {
    final url = Uri.http(baseUrl, "smartlist/list/delete/");
    String body = json.encode({
      "user_pk": user.pk,
      "pk": shoppingList.pk
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }

  static Future buyShoppingListItem(User user, ShoppingListObject item) async {
    final url = Uri.http(baseUrl, "smartlist/list/buy/");
    String body = json.encode({
      "user_pk": user.pk,
      "pk": item.pk
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }

  static Future unbuyShoppingListItem(User user, ShoppingListObject item) async {
    final url = Uri.http(baseUrl, "smartlist/list/unbuy/");
    String body = json.encode({
      "user_pk": user.pk,
      "pk": item.pk
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }

  static Future deleteShoppingListItem(User user, ShoppingListObject item) async {
    final url = Uri.http(baseUrl, "smartlist/list/remove/");
    String body = json.encode({
      "user_pk": user.pk,
      "pk": item.pk
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }

  static Future wipeShoppingList(User user, ShoppingList shoppingList) async {
    final url = Uri.http(baseUrl, "smartlist/list/wipe/");
    String body = json.encode({
      "user_pk": user.pk,
      "pk": shoppingList.pk
    });
    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }

  static Future getShoppingListMembers(User user, ShoppingList shoppingList) async {
    final getParams = {
      "user_pk": user.pk.toString(),
      "list_pk": shoppingList.pk.toString()
    };
    List<User> listMembers = new List<User>();

    final url = Uri.http(baseUrl, "smartlist/list/getmembers/", getParams);
    final Response response = await get(url);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      for (String pk in responseMap.keys) {
        final userData = responseMap[pk];

        // Create the user object and add it to the users list
        listMembers.add(new User(name: userData['name'], pk: int.parse(pk)));
      }
    }

    return listMembers;
  }

  static Future removeUserFromList(User user, User userToRemove, ShoppingList shoppingList) async {
    final url = Uri.http(baseUrl, "smartlist/user/exitlist/");
    String body = json.encode({
      "user_pk": user.pk,
      "remove_user_pk": userToRemove.pk,
      "shopping_list_pk": shoppingList.pk
    });

    final Response response = await post(url, body: body);
    final responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }
    else {
      return Error(errorStatement: responseMap['error']);
    }
  }
}