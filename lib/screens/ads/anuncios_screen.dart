// REMOVIBLE-PRUEBA: pantalla completa de anuncios demo con AdMob (test IDs)
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../theme/app_theme.dart';

// REMOVIBLE-PRUEBA: test ad unit IDs públicos de Google (no usar en producción)
class _AdUnits {
  static String get banner {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return '';
  }

  static String get interstitial {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    return '';
  }
}

// REMOVIBLE-PRUEBA: pantalla de Anuncios (sección demo)
class AnunciosScreen extends StatefulWidget {
  const AnunciosScreen({super.key});

  @override
  State<AnunciosScreen> createState() => _AnunciosScreenState();
}

class _AnunciosScreenState extends State<AnunciosScreen> {
  // REMOVIBLE-PRUEBA: estado del banner
  BannerAd? _bannerAd;
  bool _bannerListo = false;

  // REMOVIBLE-PRUEBA: estado del intersticial
  InterstitialAd? _interstitialAd;
  bool _interstitialListo = false;
  bool _cargandoInterstitial = false;

  @override
  void initState() {
    super.initState();
    // REMOVIBLE-PRUEBA: cargar ads al abrir la pantalla
    _cargarBanner();
    _cargarInterstitial();
  }

  @override
  void dispose() {
    // REMOVIBLE-PRUEBA: liberar recursos de los ads
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // REMOVIBLE-PRUEBA: carga del banner ad
  void _cargarBanner() {
    if (kIsWeb) return;
    final ad = BannerAd(
      adUnitId: _AdUnits.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _bannerListo = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
    _bannerAd = ad;
  }

  // REMOVIBLE-PRUEBA: carga del intersticial
  void _cargarInterstitial() {
    if (kIsWeb) return;
    setState(() => _cargandoInterstitial = true);
    InterstitialAd.load(
      adUnitId: _AdUnits.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (mounted) {
            setState(() {
              _interstitialListo = true;
              _cargandoInterstitial = false;
            });
          }
        },
        onAdFailedToLoad: (error) {
          if (mounted) {
            setState(() {
              _interstitialListo = false;
              _cargandoInterstitial = false;
            });
          }
        },
      ),
    );
  }

  // REMOVIBLE-PRUEBA: mostrar el intersticial cargado
  void _mostrarInterstitial() {
    final ad = _interstitialAd;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        if (mounted) setState(() => _interstitialListo = false);
        _cargarInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        if (mounted) setState(() => _interstitialListo = false);
      },
    );
    ad.show();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVIBLE-PRUEBA: contenido completo de la sección Anuncios
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Anuncios',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Espacio publicitario · demo con anuncios de prueba de Google',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // REMOVIBLE-PRUEBA: aviso visual de que es demo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentDark,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Estos anuncios son de prueba (Google AdMob test IDs) y no generan ingresos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Banner',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // REMOVIBLE-PRUEBA: contenedor del banner ad
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            padding: const EdgeInsets.all(12),
            child: _bannerListo && _bannerAd != null
                ? SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )
                : const _PlaceholderAd(
                    titulo: 'Cargando banner…',
                    altura: 50,
                  ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Anuncio intersticial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantalla completa que se muestra al pulsar el botón',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // REMOVIBLE-PRUEBA: botón para disparar el intersticial
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _interstitialListo ? _mostrarInterstitial : null,
              icon: const Icon(Icons.play_circle_outline, size: 20),
              label: Text(
                _cargandoInterstitial
                    ? 'Cargando anuncio…'
                    : _interstitialListo
                        ? 'Mostrar anuncio'
                        : 'Anuncio no disponible',
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!_interstitialListo && !_cargandoInterstitial)
            TextButton.icon(
              onPressed: _cargarInterstitial,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }
}

// REMOVIBLE-PRUEBA: placeholder mientras carga el banner
class _PlaceholderAd extends StatelessWidget {
  final String titulo;
  final double altura;

  const _PlaceholderAd({required this.titulo, required this.altura});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: altura,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
