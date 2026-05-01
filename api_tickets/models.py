from django.db import models
from django.contrib.auth.models import User

from django.db.models.signals import post_save
from django.dispatch import receiver

class PerfilUsuario(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil')
    saldo = models.DecimalField(max_digits=10, decimal_places=2, default=500.00) # Empezamos con 500 pesos de regalo

    def __str__(self):
        return f"Perfil de {self.usuario.username} - Saldo: ${self.saldo}"

@receiver(post_save, sender=User)
def crear_perfil_usuario(sender, instance, created, **kwargs):
    if created:
        PerfilUsuario.objects.create(usuario=instance)

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
