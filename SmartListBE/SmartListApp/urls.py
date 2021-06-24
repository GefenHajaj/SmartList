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

    path(
        'user/addlist/',
        views.UserViews.join_list,
        name="user_join_list"
    ),

    path(
        'user/exitlist/',
        views.UserViews.exit_list,
        name="user_exit_list"
    ),

    path(
        'user/connect/',
        views.UserViews.connect,
        name="connect"
    ),

    path(
        'list/objects/',
        views.ShoppingListViews.get_all_objects,
        name="get_all_objects"
    ),

    path(
        'list/info/',
        views.ShoppingListViews.get_list_info,
        name="get_list_info"
    ),

    path(
        'list/add/',
        views.ShoppingListViews.add_item_to_list,
        name="add_item_to_list"
    ),

    path(
        'list/remove/',
        views.ShoppingListViews.remove_item_from_list,
        name="remove_item_from_list"
    ),

    path(
        'list/buy/',
        views.ShoppingListViews.mark_item_as_bought,
        name="mark_item_as_bought"
    ),

    path(
        'list/unbuy/',
        views.ShoppingListViews.mark_item_as_unbought,
        name="mark_item_as_unbought"
    ),

    path(
        'list/delete/',
        views.ShoppingListViews.delete_shopping_list,
        name="delete_shopping_list"
    ),

    path(
        'list/create/',
        views.ShoppingListViews.create_shopping_list,
        name="create_shopping_list"
    ),

    path(
        'list/wipe/',
        views.ShoppingListViews.wipe_shopping_list,
        name="wipe_shopping_list"
    ),

    path(
        'list/getmembers/',
        views.ShoppingListViews.get_all_list_members,
        name="get_all_list_members"
    ),

    path(
        'item/changeunit/',
        views.ListObjectViews.change_item_unit,
        name="change_item_unit"
    ),

    path(
        'item/changeamount/',
        views.ListObjectViews.change_item_amount,
        name="change_item_amount"
    ),

    path(
        'item/change/',
        views.ListObjectViews.change_list_item,
        name="change_list_item"
    ),

    path(
        'product/autocomplete/',
        views.ProductViews.items_autocomplete,
        name="items_autocomplete"
    ),
]
