from django.contrib import admin
from .models import Boleto

@admin.register(Boleto)
class BoletoAdmin(admin.ModelAdmin):
    list_display = ('codigo_alfanumerico', 'usuario', 'identificador_invitado', 'fecha_compra', 'estado')
    list_filter = ('estado', 'fecha_compra')
    search_fields = ('codigo_alfanumerico',)
