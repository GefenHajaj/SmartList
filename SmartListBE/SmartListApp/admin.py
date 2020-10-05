from django.contrib import admin

from .models import *

admin.site.register(User)
admin.site.register(ShoppingList)
admin.site.register(Product)
admin.site.register(ListObject)
