from django.db import models


class User(models.Model):
    name = models.CharField(max_length=50)
    creation_time = models.DateTimeField(auto_now_add=True)
    last_connected = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "User: {} ({})".format(self.name, self.pk)


class ShoppingList(models.Model):
    name = models.CharField(max_length=50)
    owner = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='owned_lists'
    )
    editors = models.ManyToManyField(User)
    unique_id = models.CharField(max_length=10)
    creation_time = models.DateTimeField(auto_now_add=True)
    last_changed = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "Shopping List: {} ({})".format(self.name, self.pk)


class Product(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return "Product: {} ({})".format(self.name, self.pk)


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

    def __str__(self):
        return "List Object: {} ({})".format(self.product.name, self.pk)

