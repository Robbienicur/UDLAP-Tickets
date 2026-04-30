from django.urls import path
from . import views

urlpatterns = [
    path('boletos/', views.get_boletos, name='get_boletos'),
    path('boletos/comprar/', views.comprar_boletos, name='comprar_boletos'),
    path('auth/login/', views.login_view, name='login'),
]
