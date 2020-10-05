from django.urls import path
from . import views

urlpatterns = [
    path(
        'user/register/',
        views.UserViews.create_user,
        name='create_user'
    ),

    path(
        'user/details/',
        views.UserViews.get_user_details,
        name="get_user_details"
    ),

    path(
        'user/lists/',
        views.UserViews.get_user_all_lists,
        name="get_user_all_lists"
    ),

    # TODO: Check this
    path(
        'user/addlist/',
        views.UserViews.join_list,
        name="user_join_list"
    ),

    # TODO: Check this
    path(
        'user/exitlist/',
        views.UserViews.exit_list,
        name="user_exit_list"
    ),


]
