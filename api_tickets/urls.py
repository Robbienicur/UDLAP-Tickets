from django.urls import path
from . import views

urlpatterns = [
    path('boletos/', views.get_boletos, name='get_boletos'),
    path('boletos/comprar/', views.comprar_boletos, name='comprar_boletos'),
    path('boletos/consumir/', views.consumir_boleto, name='consumir_boleto'),
    path('auth/login/', views.login_view, name='login'),
    path('auth/register/', views.registrar_usuario, name='register'),
    path('auth/request-reset/', views.request_password_reset, name='request_reset'),
    path('auth/reset-password/', views.reset_password_view, name='reset_password'),
]
