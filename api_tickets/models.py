from django.db import models
from django.contrib.auth.models import User

class Boleto(models.Model):
    ESTADO_CHOICES = [
        ('Disponible', 'Disponible'),
        ('Usado', 'Usado'),
    ]

    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='boletos', null=True, blank=True)
    identificador_invitado = models.CharField(max_length=100, null=True, blank=True) # Para usuarios invitados (IP o DeviceID)
    codigo_alfanumerico = models.CharField(max_length=50, unique=True)
    fecha_compra = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='Disponible')

    def __str__(self):
        return f"{self.codigo_alfanumerico} ({self.usuario or self.identificador_invitado})"
