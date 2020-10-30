from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from django.http import HttpResponse, HttpResponseBadRequest, \
    HttpResponseServerError
import json
from .models import *
import traceback
import decimal
import random
import hashlib
import time


class UserViews:
    # GET views
    @staticmethod
    @csrf_exempt
    def get_user_details(request):
        """
        Get details of a specific user
        :param request: django.http.request
        :return: http response.
        """
        if request.method == 'GET':
            try:
                user_pk = request.GET['pk']
                user_secret = request.GET['secret']
                user = get_object_or_404(User, pk=user_pk, secret=user_secret)
                return HttpResponse(json.dumps({
                    "pk": user.pk,
                    "name": user.name,
                    "creation_time": str(user.creation_time),
                    "last_connected": str(user.last_connected)
                }, ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "get_user_details(): should be a get request"
            )

    @staticmethod
    @csrf_exempt
    def get_user_all_lists(request):
        """
        Get all shopping lists the user is an editor or owner of.
        :param request: django.http.request
        :return: http response.
        """
        if request.method == 'GET':
            try:
                user_pk = request.GET['pk']
                user_secret = request.GET['secret']
                user = get_object_or_404(User, pk=user_pk, secret=user_secret)

                user_owned_lists = user.owned_lists.all()
                user_editor_lists = user.shoppinglist_set.all()
                user_lists = user_owned_lists | user_editor_lists
                user_lists = user_lists.order_by('creation_time')
                user_lists_info = {}
                for shopping_list in user_lists:
                    user_lists_info[shopping_list.pk] = {
                        "name": shopping_list.name,
                        "unique_id": shopping_list.unique_id,
                        "owner_pk": shopping_list.owner.pk,
                        "owner_name": shopping_list.owner.name
                    }
                return HttpResponse(json.dumps(user_lists_info,
                                               ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(json.dumps({
              "error": "get_user_all_lists(): should be a get request"
            }))

    # POST views
    @staticmethod
    @csrf_exempt
    def create_user(request):
        """
        Create a new user and save it.
        For it tow work we need:
        username, password, email (not required), phone number (not required).
        :param request: django.http.request
        :return: http response.
        """
        # Make sure the request is a POST
        if request.method == 'POST':
            try:
                user_info = json.loads(request.body)
                secret = hashlib.sha1(
                    (user_info['name'] + time.ctime() + "secret").encode()
                ).hexdigest()
                # Create the new user:
                new_user = User(
                    name=user_info['name'],
                    secret=secret
                )
                new_user.save()
                return HttpResponse(json.dumps({
                    "name": new_user.name,
                    "secret": new_user.secret,
                    "pk": new_user.pk
                }, ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e,
                                                                     traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(json.dumps(
                {"error": "create_user(): should be a post request"}
            ))

    @staticmethod
    @csrf_exempt
    def connect(request):
        # Make sure the request is a POST
        if request.method == 'POST':
            try:
                user_info = json.loads(request.body)
                # Get the user
                user = get_object_or_404(
                    User,
                    pk=user_info['pk'],
                    secret=user_info['secret']
                )
                user.save()

                return HttpResponse(json.dumps({
                    "success": "user {} logged in".format(user.name)
                }, ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e,
                                                                     traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(json.dumps(
                {"error": "connect(): should be a post request"}
            ))

    @staticmethod
    @csrf_exempt
    def join_list(request):
        """
        This will allow a user to join an existing list.
        Needed info: pk of user, pk of list, name of list, unique_id of list
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                user = get_object_or_404(User,
                                         pk=info['user_pk'],
                                         secret=info['user_secret'])
                shopping_list = get_object_or_404(
                    ShoppingList,
                    unique_id=info['list_unique_id']
                )

                # Make sure the user is not already there.
                all_users = shopping_list.editors.all()
                all_users_pks = [user.pk for user in all_users]
                all_users_pks.append(shopping_list.owner.pk)
                if not info['user_pk'] in all_users_pks:
                    shopping_list.editors.add(user)

                return HttpResponse(json.dumps({
                    "name": shopping_list.name,
                    "pk": shopping_list.pk,
                    "owner_pk": shopping_list.owner.pk,
                    "owner_name": shopping_list.owner.name,

                }, ensure_ascii=False))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "join_list(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def exit_list(request):
        """
        Allow a user to exit the list.
        The user that wants to exit must supply his session or the owner
        of the list's session (not for now).
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)

                removing_user = get_object_or_404(
                    User,
                    pk=info['removing_pk'],
                    secret=info['removing_secret'])
                user = get_object_or_404(User, pk=info['remove_user_pk'])
                shopping_list = get_object_or_404(ShoppingList,
                                                  pk=info['shopping_list_pk'])

                # Make sure the user is authorized
                editors_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks = editors_pks + [shopping_list.owner.pk]
                if removing_user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                if user.pk in editors_pks:
                    shopping_list.editors.remove(user)
                    shopping_list.save()
                    return HttpResponse(json.dumps({
                        "success": "user {} removed from shopping list {}".format(user.pk, shopping_list.pk)
                    }))
                elif user.pk == shopping_list.owner.pk:
                    return HttpResponse(json.dumps({
                        "success": "cannot remove owner".format(
                            user.pk, shopping_list.pk)
                    }))
                else:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "user not in list"}
                    ))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "exit_list(): should be a post request"
            )


class ShoppingListViews:
    # GET views
    @staticmethod
    @csrf_exempt
    def get_all_objects(request):
        """
        Get all the objects in the list.
        :param request:delete_shopping_list django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'GET':
            try:
                list_pk = request.GET['pk']
                user = get_object_or_404(
                    User,
                    pk=request.GET['user_pk'],
                    secret=request.GET['user_secret'])
                shopping_list = get_object_or_404(ShoppingList, pk=list_pk)

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                all_objects = shopping_list.listobject_set.all()
                objects_info = {}
                for obj in all_objects:
                    objects_info[obj.pk] = {
                        "name": obj.product.name,
                        "product_pk": obj.product.pk,
                        "units": obj.units,
                        "amount": float(obj.amount),
                        "user_added_name": obj.user_added.name,
                        "user_added_pk": obj.user_added.pk,
                        "is_bought": obj.is_bought,
                    }
                return HttpResponse(json.dumps(objects_info,
                                               ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "get_all_objects(): should be a get request"
            )

    @staticmethod
    @csrf_exempt
    def get_list_info(request):
        """
        Get all info about a specific list.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'GET':
            try:
                list_pk = request.GET['pk']
                shopping_list = get_object_or_404(ShoppingList, pk=list_pk)
                user = get_object_or_404(
                    User,
                    pk=request.GET['user_pk'],
                    secret=request.GET['user_secret'])

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                shopping_list_info = {
                    "pk": shopping_list.pk,
                    "name": shopping_list.name,
                    "owner_name": shopping_list.owner.name,
                    "owner_pk": shopping_list.owner.pk,
                    "unique_id": shopping_list.unique_id,
                    "creation_time": str(shopping_list.creation_time),
                    "last_changed": str(shopping_list.last_changed)
                }

                return HttpResponse(json.dumps(shopping_list_info,
                                               ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "get_list_info(): should be a get request"
            )

    @staticmethod
    @csrf_exempt
    def get_all_list_members(request):
        """
        Get all the users that are editors or owners of a list,
        Not including the user that requested the detail.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'GET':
            try:
                user_pk = request.GET['user_pk']
                user_secret = request.GET['user_secret']
                list_pk = request.GET['list_pk']

                # Get the shopping list and the user
                shopping_list = get_object_or_404(ShoppingList, pk=list_pk)
                user = get_object_or_404(
                    User,
                    pk=user_pk,
                    secret=user_secret)

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                # Get the list of people in that list
                editors = shopping_list.editors.all()
                owner = shopping_list.owner

                final_data = {}

                # Add all the members of the list to the final data
                for editor in editors:
                    if str(editor.pk) != user_pk:
                        final_data[editor.pk] = {
                            "name": editor.name
                        }
                if str(owner.pk) != user_pk and owner.pk not in final_data:
                    final_data[owner.pk] = {
                        "name": owner.name
                    }

                # return the data
                return HttpResponse(json.dumps(final_data, ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "get_all_list_members(): should be a get request"
            )


    # POST views
    @staticmethod
    @csrf_exempt
    def add_item_to_list(request):
        """
        Add item to a list.
        This function also creates the item.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)

                # Get the user who added the object
                user = get_object_or_404(User,
                                         pk=info['user_pk'],
                                         secret=info['user_secret'])

                # Get the shopping list to add the item to
                shopping_list = get_object_or_404(ShoppingList,
                                                  pk=info['list_pk'])

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                # Check that product exists - if not, create it
                product_name = info['product_name']
                if not product_name:
                    raise KeyError
                elif not Product.objects.filter(name=product_name).count():
                    product = Product(name=product_name)
                    product.save()
                else:
                    product = Product.objects.get(name=product_name)

                # Create the new item we'll add to the list
                list_item = ListObject(
                    product=product,
                    units=info['units'],
                    amount=decimal.Decimal(info['amount']),
                    user_added=user,
                    shopping_list=shopping_list
                )
                list_item.save()
                return HttpResponse(json.dumps({
                    "pk": list_item.pk,
                    "product_pk": list_item.product.pk,
                }, ensure_ascii=False))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "add_item_to_list(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def remove_item_from_list(request):
        """
        Remove item from a list (delete it!)
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)

                # Get the user who added the object
                user = get_object_or_404(User,
                                         pk=info['user_pk'],
                                         secret=info['user_secret'])

                # Get the shopping list to add the item to
                shopping_list = get_object_or_404(ShoppingList,
                                                  pk=info['list_pk'])

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                # Make sure item is part of list
                all_items_pks = [item.pk for item in shopping_list.listobject_set.all()]
                if info['pk'] not in all_items_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                item = get_object_or_404(ListObject, pk=info['pk'])
                item.delete()
                return HttpResponse(json.dumps({
                    "success": "item {} ({}) removed from list {}".format(
                        item.product.name,
                        info['pk'],
                        item.shopping_list.pk
                    )
                }, ensure_ascii=False))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "remove_item_from_list(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def mark_item_as_bought(request):
        """
        Mark an item as bought.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)

                # Get the user who added the object
                user = get_object_or_404(User,
                                         pk=info['user_pk'],
                                         secret=info['user_secret'])

                # Get the shopping list to add the item to
                shopping_list = get_object_or_404(ShoppingList,
                                                  pk=info['list_pk'])

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                # Make sure item is part of list
                all_items_pks = [item.pk for item in
                                 shopping_list.listobject_set.all()]
                if info['pk'] not in all_items_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                item = get_object_or_404(ListObject, pk=info['pk'])
                item.is_bought = True
                item.save()

                return HttpResponse(json.dumps({
                    "success": "item {} ({}) was bought".format(
                        item.product.name,
                        item.pk
                    )
                }, ensure_ascii=False))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "mark_item_as_bought(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def mark_item_as_unbought(request):
        """
        Mark an item as bought.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)

                # Get the user who added the object
                user = get_object_or_404(User,
                                         pk=info['user_pk'],
                                         secret=info['user_secret'])

                # Get the shopping list to add the item to
                shopping_list = get_object_or_404(ShoppingList,
                                                  pk=info['list_pk'])

                # Make sure user is part of list
                all_pks = [u.pk for u in shopping_list.editors.all()]
                all_pks.append(shopping_list.owner.pk)
                if user.pk not in all_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                # Make sure item is part of list
                all_items_pks = [item.pk for item in
                                 shopping_list.listobject_set.all()]
                if info['pk'] not in all_items_pks:
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "not authorized"}
                    ))

                item = get_object_or_404(ListObject, pk=info['pk'])
                item.is_bought = False
                item.save()

                return HttpResponse(json.dumps({
                    "success": "item {} ({}) was UNbought".format(
                        item.product.name,
                        item.pk
                    )
                }, ensure_ascii=False))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e,
                                                                     traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "mark_item_as_bought(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def delete_shopping_list(request):
        """
        Delete a shopping list
        :param request:
        :return:
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                # TODO: Make sure the user who delete's the shopping list is
                # The owner or one of the editors of the list.
                shopping_list = get_object_or_404(ShoppingList, pk=info['pk'])

                # Delete all the items in the list
                for item in shopping_list.listobject_set.all():
                    item.delete()

                # Delete the list
                shopping_list.delete()

                return HttpResponse(json.dumps({
                    "success": "list {} deleted successfully".format(
                        info['pk']
                    )
                }))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "delete_shopping_list(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def create_shopping_list(request):
        """
        Create a new empty shopping list
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                created_user = get_object_or_404(User, pk=info['user_pk'])

                # Generate an 8-digit random unique id
                unique_id = str(random.randint(10000000, 100000000))
                while ShoppingList.objects.filter(unique_id=unique_id).count():
                    unique_id = str(random.randint(10000000, 100000000))

                if not info['name']:
                    return HttpResponseBadRequest(json.dumps({
                        "error": "list name can't be empty"
                    }))
                new_list = ShoppingList(
                    name=info['name'],
                    owner=created_user,
                    unique_id=unique_id,
                )
                new_list.save()
                return HttpResponse(json.dumps({
                    "name": new_list.name,
                    "unique_id": new_list.unique_id,
                    "pk": new_list.pk
                }, ensure_ascii=False))

            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "create_list(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def wipe_shopping_list(request):
        """
        Delete all items in a list.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                shopping_list = get_object_or_404(ShoppingList, pk=info['pk'])

                # Delete all the items in the list
                for item in shopping_list.listobject_set.all():
                    item.delete()
                shopping_list.save()

                return HttpResponse(json.dumps({
                    "success": "removed all items from shopping list {}".format(
                        shopping_list.pk
                    )
                }))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "wipe_shopping_list(): should be a post request"
            )


class ListObjectViews:
    # POST views
    @staticmethod
    @csrf_exempt
    def change_item_unit(request):
        """
        Change an item's units.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                item = get_object_or_404(ListObject, pk=info['pk'])
                item.units = info['units']
                item.save()

                return HttpResponse(json.dumps({
                    "success": "list item {} changed to units {}".format(
                        item.pk,
                        item.units
                    )
                }))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "change_item_unit(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def change_item_amount(request):
        """
        Change an item's amount.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                item = get_object_or_404(ListObject, pk=info['pk'])
                item.amount = info['amount']
                item.save()

                return HttpResponse(json.dumps({
                    "success": "list item {} changed to amount {}".format(
                        item.pk,
                        item.amount
                    )
                }))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e, traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "change_item_unit(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def change_list_item(request):
        """
        Change item's properties.
        :param request: django.http.request
        :return: django.http.HttpResponse
        """
        if request.method == 'POST':
            try:
                info = json.loads(request.body)
                item = get_object_or_404(ListObject, pk=info['pk'])
                item.amount = info['amount']
                item.units = info['units']
                item.product.name = info['name']
                item.save()

                return HttpResponse(json.dumps({
                    "success": "list item {} changed to amount {}".format(
                        item.pk,
                        item.amount
                    )
                }))
            except KeyError:
                return HttpResponseBadRequest(json.dumps(
                    {"error": "not enough data supplied"}
                ))
            except Exception as e:
                return HttpResponseServerError(json.dumps(
                    {"error": "something went wrong.\n{}: {}".format(e,
                                                                     traceback.format_exc())}
                ))
        else:
            return HttpResponseBadRequest(
                "change_list_item(): should be a post request"
            )

