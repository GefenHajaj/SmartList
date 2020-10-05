from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from django.http import HttpResponse, HttpResponseBadRequest, \
    HttpResponseServerError
from django.utils import timezone
from datetime import datetime
from django.core.exceptions import ObjectDoesNotExist
import json
from .models import *
import os
import hashlib
import traceback


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
                user = get_object_or_404(User, pk=user_pk)
                return HttpResponse(json.dumps({
                    "pk": user.pk,
                    "name": user.name,
                    "email": user.email,
                    "phone_number": user.phone_number,
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
                user = get_object_or_404(User, pk=user_pk)

                user_owned_lists = user.owned_lists.all()
                user_editor_lists = user.shoppinglist_set.all()
                user_lists = user_owned_lists | user_editor_lists
                user_lists = user_lists.order_by('creation_time')
                user_lists_info = {}
                for shopping_list in user_lists:
                    user_lists_info[shopping_list.pk] = shopping_list.name
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
            return HttpResponseBadRequest(
                "get_all_lists(): should be a get request"
            )

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

                # Check if mail already taken
                if User.objects.filter(email=user_info['email']).count():
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "email taken"}
                    ))
                # Check if phone already taken
                if User.objects.filter(phone_number=user_info['phone_number']).count():
                    return HttpResponseBadRequest(json.dumps(
                        {"error": "phone_number taken"}
                    ))

                # Create the new user:
                new_user = User(
                    name=user_info['name'],
                    password=hashlib.sha1(user_info['password'].encode()).hexdigest(),
                    email=user_info['email'],
                    phone_number=user_info['phone_number'],
                )
                new_user.save()
                return HttpResponse(json.dumps({
                    "name": new_user.name,
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
            return HttpResponseBadRequest(
                "create_user(): should be a post request"
            )

    @staticmethod
    @csrf_exempt
    def connect(request):
        return HttpResponseServerError(json.dumps(
            {"error": "this function is not yet ready"}
        ))

    @staticmethod
    @csrf_exempt
    def update_user_info(request):
        return HttpResponseServerError(json.dumps(
            {"error": "this function is not yet ready"}
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
                user = get_object_or_404(User, pk=info['user_pk'])
                shopping_list = get_object_or_404(User,
                                                  pk=info['list_pk'],
                                                  name=info['list_name'],
                                                  unique_id=info['list_unique_id'])
                shopping_list.editors.add(user)
                return HttpResponse(json.dumps({
                    "success": "added user {} to list {}".format(
                        user.pk,
                        shopping_list.pk
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
                # TODO: Check that everything is valid

                user = get_object_or_404(User, pk=info['remove_user_pk'])
                shopping_list = get_object_or_404(ShoppingList,
                                                  pk=info['shopping_list_pk'])
                shopping_list.editors.remove(user)
                return HttpResponse(json.dumps({
                    "success": "user {} removed from shopping list {}".format(
                        user.pk,
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
                "exit_list(): should be a post request"
            )

