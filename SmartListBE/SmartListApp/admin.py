from django.contrib import admin

from .models import *


class UserAdmin(admin.ModelAdmin):
    readonly_fields = ('last_connected',)


class ShoppingListAdmin(admin.ModelAdmin):
    readonly_fields = ('last_changed',)


class ListObjectAdmin(admin.ModelAdmin):
    readonly_fields = ('creation_time',)


admin.site.register(User, UserAdmin)
admin.site.register(ShoppingList, ShoppingListAdmin)
admin.site.register(Product)
admin.site.register(ListObject, ListObjectAdmin)


