from django.db import models


class User(models.Model):
    name = models.CharField(max_length=50)
    password = models.CharField(max_length=50)
    email = models.EmailField(max_length=254)
    phone_number = models.CharField(max_length=15)
    creation_time = models.DateTimeField(auto_now_add=True)
    last_connected = models.DateTimeField(auto_now=True)


class ShoppingList(models.Model):
    name = models.CharField(max_length=50)
    owner = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='list_owner'
    )
    editors = models.ManyToManyField(User)
    creation_time = models.DateTimeField(auto_now_add=True)
    last_changed = models.DateTimeField(auto_now=True)


class Product(models.Model):
    name = models.CharField(max_length=100)


class ListObject(models.Model):
    KILOGRAMS_UNIT = 'kg'
    UNITS_UNIT = 'units'
    UNITS_OPTIONS = [
        (KILOGRAMS_UNIT, 'Kilograms'),
        (UNITS_UNIT, 'How many'),
    ]

    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    units = models.CharField(
        max_length=10,
        choices=UNITS_OPTIONS,
        default=UNITS_UNIT
    )
    amount = models.DecimalField(max_digits=3, decimal_places=1, default=1.0)
    user_added = models.ForeignKey(User, on_delete=models.CASCADE)
    is_bought = models.BooleanField(default=False)
    shopping_list = models.ForeignKey(ShoppingList, on_delete=models.CASCADE)


