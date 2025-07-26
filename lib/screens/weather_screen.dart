// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientAnimation;
  final Color violet = const Color(0xFF8F5CFF);
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic>? weather;
  List<Map<String, dynamic>>? forecast;
  bool loading = false;
  bool loadingForecast = false;
  String error = '';
  List<String> favoriteCities = [];
  String? currentCity;

  List<Map<String, dynamic>> citySuggestions = [];
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _gradientAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(_controller);

    _loadFavorites();
    _fetchCurrentLocationWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      favoriteCities = prefs.getStringList('favorite_cities') ?? [];
    });
  }

  Future<void> _toggleFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      if (favoriteCities.contains(city)) {
        favoriteCities.remove(city);
      } else {
        favoriteCities.add(city);
      }
      prefs.setStringList('favorite_cities', favoriteCities);
    });
  }

  Future<void> _fetchCurrentLocationWeather() async {
    setState(() {
      loading = true;
      error = '';
      currentCity = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          error = 'Location permission denied.';
          loading = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final data = await WeatherService.fetchWeatherByCoords(
          position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        weather = data;
        currentCity = "${data['city']}, ${data['country']}";
        loading = false;
      });
      _fetchForecast(
        double.parse(data['coord']['lat'].toString()),
        double.parse(data['coord']['lon'].toString()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to get weather: $e';
        loading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCoordsAndSet(
      double lat, double lon, String displayName) async {
    setState(() {
      loading = true;
      error = '';
    });
    final data = await WeatherService.fetchWeatherByCoords(lat, lon);
    if (!mounted) return;
    setState(() {
      weather = data;
      currentCity = displayName;
      loading = false;
    });
    _fetchForecast(lat, lon);
  }

  Future<void> _fetchCityWeather(String city) async {
    setState(() {
      loading = true;
      error = '';
      showSuggestions = false;
    });
    final data = await WeatherService.fetchWeatherByCity(city);
    if (data == null) {
      if (!mounted) return;
      setState(() {
        error = 'City not found.';
        loading = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      weather = data;
      currentCity = "${data['city']}, ${data['country']}";
      loading = false;
    });
    _fetchForecastByCity(city);
  }

  Future<void> _fetchForecast(double lat, double lon) async {
    setState(() {
      loadingForecast = true;
    });
    forecast = await WeatherService.fetch5DayForecast(lat, lon);
    if (!mounted) return;
    setState(() {
      loadingForecast = false;
    });
  }

  Future<void> _fetchForecastByCity(String city) async {
    final data = await WeatherService.fetchWeatherByCity(city);
    if (data != null && data['coord'] != null) {
      await _fetchForecast(
        double.parse(data['coord']['lat'].toString()),
        double.parse(data['coord']['lon'].toString()),
      );
    }
  }

  void _onSearchChanged(String value) async {
    if (value.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        citySuggestions = [];
        showSuggestions = false;
      });
      return;
    }
    final suggestions = await WeatherService.citySuggestions(value.trim());
    if (!mounted) return;
    setState(() {
      citySuggestions = suggestions;
      showSuggestions = true;
    });
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeProvider>(context);
    final isDark = themeNotifier.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text('Weather', style: GoogleFonts.poppins(color: violet)),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: violet, size: 30),
            onPressed: _fetchCurrentLocationWeather,
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: violet.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.poppins(
                                  color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: "Search city...",
                                hintStyle: GoogleFonts.poppins(
                                    color:
                                        isDark ? Colors.grey : Colors.black54),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              onChanged: _onSearchChanged,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _fetchCityWeather(value.trim());
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor: violet,
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                _fetchCityWeather(
                                    _searchController.text.trim());
                              }
                            },
                          ),
                        ),
                        if (currentCity != null) ...[
                          const SizedBox(width: 16),
                          CircleAvatar(
                            backgroundColor:
                                favoriteCities.contains(currentCity)
                                    ? violet
                                    : Colors.transparent,
                            child: IconButton(
                              icon: Icon(
                                favoriteCities.contains(currentCity)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: favoriteCities.contains(currentCity)
                                    ? Colors.white
                                    : violet,
                              ),
                              onPressed: () => _toggleFavorite(currentCity!),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (favoriteCities.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favoriteCities.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    _fetchCityWeather(favoriteCities[index]),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[900]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: violet.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    favoriteCities[index],
                                    style: GoogleFonts.poppins(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (loading)
                      Center(child: CircularProgressIndicator(color: violet)),
                    if (!loading && error.isNotEmpty)
                      Text(error,
                          style: GoogleFonts.poppins(color: Colors.red)),
                    if (!loading && weather != null) ...[
                      _WeatherCard(
                        weather: weather!,
                        violet: violet,
                        isDark: isDark,
                        formatTime: _formatTime,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '5-Day Forecast',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (loadingForecast)
                        Center(child: CircularProgressIndicator(color: violet))
                      else if (forecast != null)
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: forecast!.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return _ForecastCard(
                                forecast: forecast![index],
                                primaryColor: violet,
                                isDark: isDark,
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (showSuggestions && citySuggestions.isNotEmpty)
                Positioned(
                  top: 70,
                  left: 24,
                  right: 24,
                  child: Material(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: citySuggestions.length,
                      itemBuilder: (context, index) {
                        final city = citySuggestions[index];
                        final displayName = [
                          city['name'],
                          city['admin2'] ?? city['admin1'],
                          city['country']
                        ].where((e) => e != null && e.isNotEmpty).join(', ');
                        return ListTile(
                          title: Text(
                            displayName,
                            style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black),
                          ),
                          onTap: () async {
                            _searchController.text = displayName;
                            await _fetchWeatherByCoordsAndSet(
                              city['latitude'],
                              city['longitude'],
                              displayName,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weather;
  final Color violet;
  final bool isDark;
  final String Function(dynamic) formatTime;

  const _WeatherCard({
    required this.weather,
    required this.violet,
    required this.isDark,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: violet.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: violet.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (weather['icon']?.toString().isNotEmpty ?? false)
            Image.network(
              WeatherService.iconUrl(weather['icon']),
              width: 60,
              height: 60,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.cloud, color: violet, size: 48),
            )
          else
            Icon(Icons.cloud, color: violet, size: 48),
          const SizedBox(height: 12),
          Text(
            '${weather['temp']}°C',
            style: GoogleFonts.poppins(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            weather['city'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            weather['desc'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? Colors.grey : Colors.black54,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WeatherDetail(
                icon: Icons.water_drop,
                value: '${weather['humidity']}%',
                label: 'Humidity',
                color: Colors.blue,
                isDark: isDark,
              ),
              _WeatherDetail(
                icon: Icons.air,
                value: '${weather['wind']} m/s',
                label: 'Wind',
                color: Colors.green,
                isDark: isDark,
              ),
              _WeatherDetail(
                icon: Icons.wb_sunny,
                value: formatTime(weather['sunrise']),
                label: 'Sunrise',
                color: Colors.orange,
                isDark: isDark,
              ),
              _WeatherDetail(
                icon: Icons.nightlight,
                value: formatTime(weather['sunset']),
                label: 'Sunset',
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _WeatherDetail({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey : Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final Map<String, dynamic> forecast;
  final Color primaryColor;
  final bool isDark;

  const _ForecastCard({
    required this.forecast,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            forecast['date'],
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (forecast['icon']?.toString().isNotEmpty ?? false)
            Image.network(
              WeatherService.iconUrl(forecast['icon']),
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.cloud, color: primaryColor, size: 32),
            )
          else
            Icon(Icons.cloud, color: primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            '${forecast['temp']}°C',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            forecast['desc'],
            style: GoogleFonts.poppins(
              color: isDark ? Colors.grey : Colors.black54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
